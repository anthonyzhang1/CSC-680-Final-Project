import CoreData

protocol StoreType {
    /// Retrieves all of the decks.
    func getAllDecks() throws -> [Deck]
    
    /// Inserts a deck into the store.
    func insertDeck(_ deck: Deck) throws
    
    /// Deletes a deck from the store.
    func deleteDeck(_ deck: Deck) throws
    
    /// Gets all the due basic cards from a deck.
    func getDueBasicCardsFromDeck(_ deck: Deck) throws -> [BasicCard]
    
    /// Gets all the due multiple choice cards from a deck.
    func getDueMultipleChoiceCardsFromDeck(_ deck: Deck) throws -> [MultipleChoiceCard]
    
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
    
    func getDueBasicCardsFromDeck(_ deck: Deck) throws -> [BasicCard] {
        let context = Self.container.viewContext
        
        // get the deck entity for the deck provided in the argument
        let fetchRequest = DeckEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", deck.id)
        let deckEntity = try context.fetch(fetchRequest)[0]
        
        // get all the basic card entities that belong to the deck
        guard let cardEntities = deckEntity.basicCards?.allObjects as? [BasicCardEntity]
        else { return [] } // supposedly will never be executed by xcode
        
        return cardEntities.compactMap { cardEntity in
            guard let id = cardEntity.id,
                  let prompt = cardEntity.prompt,
                  let solution = cardEntity.solution,
                  let creationDate = cardEntity.creationDate,
                  let dueDate = cardEntity.dueDate,
                  let nextDueDateMultiplier = cardEntity.nextDueDateMultiplier
            else { return nil }
            
            if dueDate > .now { // do not get cards not yet due
                print("due date > .now")
                return nil
            }
            
            return BasicCard(id: id, prompt: prompt, solution: solution, creationDate: creationDate, dueDate: dueDate, nextDueDateMultiplier: nextDueDateMultiplier as Decimal)
        }.sorted { $0.dueDate < $1.dueDate } // sort by due date, longest due cards first
    }
    
    // TODO
    func getDueMultipleChoiceCardsFromDeck(_ deck: Deck) throws -> [MultipleChoiceCard] {
        
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
