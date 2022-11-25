import CoreData

protocol StoreType {
    /// Retrieves all of the decks.
    func getAllDecks() throws -> [Deck]
    /// Inserts a deck into the store.
    func insertDeck(_ deck: Deck) throws
    /// Deletes a deck from the store.
    func deleteDeck(_ deck: Deck) throws
}

struct CoreDataStore: StoreType {
    private let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hitoribocchi")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Device full or data model was modified without a migration.")
            }
        }
        
        return container
    }()
    
    func getAllDecks() throws -> [Deck] {
        let context = container.viewContext
        let deckEntities = try context.fetch(DeckEntity.fetchRequest())
        
        return deckEntities.compactMap { deckEntity in
            guard
                let title = deckEntity.title,
                let id = deckEntity.id
            else { return nil }
            
            return Deck(id: id, title: title)
        }.sorted { $0.title < $1.title }
    }
    
    func insertDeck(_ deck: Deck) throws {
        let context = container.viewContext
        let entity = DeckEntity(context: context)
        entity.id = deck.id
        entity.title = deck.title
        
        print("entity:", entity) // TODO
        try context.save()
    }
    
    func deleteDeck(_ deck: Deck) throws {
        let context = container.viewContext
        let fetchRequest = DeckEntity.fetchRequest()
        
        // Find the deck in the store with the corresponding id
        fetchRequest.predicate = NSPredicate(format: "id = %@", deck.id)

        let entities = try context.fetch(fetchRequest)
        for entity in entities { context.delete(entity) } // delete all matched entities
        
        try context.save()
    }
}
