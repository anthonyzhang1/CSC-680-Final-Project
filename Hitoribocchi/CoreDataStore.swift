import CoreData

protocol StoreType {
    /// Retrieves all of the decks.
    func getAllDecks() throws -> [Deck]
    
    /// Inserts a deck into the store.
    func insertDeck(_ deck: Deck) throws
    
    /// Deletes a deck from the store.
    func deleteDeck(_ deck: Deck) throws
    
    /// Gets all the due cards from a deck.
    func getDueCardsFromDeck(_ deck: Deck) throws -> [Card]
    
    /// Inserts a basic card into a deck.
    func insertBasicCard(_ card: BasicCard, _ deck: Deck) throws
    
    /// Inserts a multiple choice card into a deck.
    func insertMultipleChoiceCard(_ card: MultipleChoiceCard, _ deck: Deck) throws
}

struct CoreDataStore: StoreType {
    private static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hitoribocchi")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error { fatalError("Device full or data model was modified without a migration.") }
        }
        
        return container
    }()
    
    func getAllDecks() throws -> [Deck] {
        let context = Self.container.viewContext
        let deckEntities = try context.fetch(DeckEntity.fetchRequest())
        
        return deckEntities.compactMap { deckEntity in
            guard let id = deckEntity.id,
                  let title = deckEntity.title
            else { return nil }
            
            return Deck(id: id, title: title)
        }.sorted { $0.title < $1.title } // sort alphabetically, in ascending order
    }
    
    func insertDeck(_ deck: Deck) throws {
        let context = Self.container.viewContext
        let entity = DeckEntity(context: context)
        entity.id = deck.id
        entity.title = deck.title
        
        try context.save()
    }
    
    func deleteDeck(_ deck: Deck) throws {
        let context = Self.container.viewContext
        let fetchRequest = DeckEntity.fetchRequest()
        
        // Find the deck in the store with the corresponding id
        fetchRequest.predicate = NSPredicate(format: "id = %@", deck.id)
        
        let entities = try context.fetch(fetchRequest)
        for entity in entities { context.delete(entity) } // delete all matched entities
        
        try context.save()
    }
    
    func getDueCardsFromDeck(_ deck: Deck) throws -> [Card] {
        let context = Self.container.viewContext
        var returnArray: [Card] // stores the cards we will return
        
        // get the deck entity for the deck provided in the argument
        let fetchRequest = DeckEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", deck.id)
        let deckEntity = try context.fetch(fetchRequest)[0]
        
        // get all the card entities that belong to the deck
        guard let basicCardEntities = deckEntity.basicCards?.allObjects as? [BasicCardEntity],
              let multipleChoiceCardEntities = deckEntity.multipleChoiceCards?.allObjects as? [MultipleChoiceCardEntity]
        else { return [] } // supposedly never executed by xcode
        
        // map the due basic cards into the return array
        returnArray = basicCardEntities.compactMap { basicCardEntity in
            guard let id = basicCardEntity.id,
                  let prompt = basicCardEntity.prompt,
                  let solution = basicCardEntity.solution,
                  let creationDate = basicCardEntity.creationDate,
                  let dueDate = basicCardEntity.dueDate,
                  let nextDueDateMultiplier = basicCardEntity.nextDueDateMultiplier
            else { return nil }
            
            if dueDate > .now { // do not get cards not yet due
                print("due date > .now")
                return nil
            }
            
            return BasicCard(id: id, prompt: prompt, solution: solution, creationDate: creationDate, dueDate: dueDate, nextDueDateMultiplier: nextDueDateMultiplier as Decimal)
        }
        
        // append to the return array the multiple choice cards
        returnArray += multipleChoiceCardEntities.compactMap { multipleChoiceCardEntity in
            guard let id = multipleChoiceCardEntity.id,
                  let prompt = multipleChoiceCardEntity.prompt,
                  let solution = multipleChoiceCardEntity.solution,
                  let creationDate = multipleChoiceCardEntity.creationDate,
                  let dueDate = multipleChoiceCardEntity.dueDate,
                  let nextDueDateMultiplier = multipleChoiceCardEntity.nextDueDateMultiplier,
                  let options = multipleChoiceCardEntity.options
            else { return nil }
            
            if dueDate > .now { // do not get cards not yet due
                print("due date > .now")
                return nil
            }
            
            return MultipleChoiceCard(id: id, prompt: prompt, solution: solution, creationDate: creationDate, dueDate: dueDate, nextDueDateMultiplier: nextDueDateMultiplier as Decimal, options: options)
        }
        
        return returnArray
    }
    
    func insertBasicCard(_ card: BasicCard, _ deck: Deck) throws {
        let context = Self.container.viewContext
        
        // get the deck entity that this card belongs to
        let fetchRequest = DeckEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", deck.id)
        let deckEntity = try context.fetch(fetchRequest)[0]
        
        let cardEntity = BasicCardEntity(context: context)
        cardEntity.id = card.id
        cardEntity.prompt = card.prompt
        cardEntity.solution = card.solution
        cardEntity.creationDate = card.creationDate
        cardEntity.dueDate = card.dueDate
        cardEntity.nextDueDateMultiplier = card.nextDueDateMultiplier as NSDecimalNumber
        cardEntity.deck = deckEntity // relationship attribute
        
        try context.save()
    }
    
    func insertMultipleChoiceCard(_ card: MultipleChoiceCard, _ deck: Deck) throws {
        let context = Self.container.viewContext
        
        // get the deck entity that this card belongs to
        let fetchRequest = DeckEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", deck.id)
        let deckEntity = try context.fetch(fetchRequest)[0]
        
        let cardEntity = MultipleChoiceCardEntity(context: context)
        cardEntity.id = card.id
        cardEntity.prompt = card.prompt
        cardEntity.solution = card.solution
        cardEntity.creationDate = card.creationDate
        cardEntity.dueDate = card.dueDate
        cardEntity.nextDueDateMultiplier = card.nextDueDateMultiplier as NSDecimalNumber
        cardEntity.options = card.options
        cardEntity.deck = deckEntity // relationship attribute
        
        try context.save()
    }
}
