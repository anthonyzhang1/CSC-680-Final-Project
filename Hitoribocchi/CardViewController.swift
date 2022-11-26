import UIKit

class CardViewController: UIViewController {
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    var dueCards: [Card] = [] // retrieved from the store and displayed to the user
    
    /// Sends the deck to the Add New Card window.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addCardViewController = segue.destination as? AddCardViewController,
           let deck = deck
        { addCardViewController.deck = deck }
    }
    
    /// Gets the cards from the store and fill the `cards` array with the retrieved cards.
    func getDueCardsFromDeck() {
        guard let deck = deck
        else { return }
        
        do { dueCards = try store.getDueBasicCardsFromDeck(deck) }
        catch { showErrorAlert("Error", "Sorry, there was an error retrieving the cards.") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the due cards to display on the screen after shuffling them
        getDueCardsFromDeck()
        dueCards = dueCards.shuffled()
        
        for card in dueCards {
            print(card)
        }
    }
}
