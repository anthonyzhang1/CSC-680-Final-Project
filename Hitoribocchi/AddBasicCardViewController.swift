import UIKit

class AddBasicCardViewController: UIViewController {
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var promptInput: UITextField!
    @IBOutlet weak var solutionInput: UITextField!
    
    @IBAction func addCardButtonClicked(_ sender: UIButton) {
        guard let prompt = promptInput.text,
              let solution = solutionInput.text,
              let deck = deck
        else { return }
        
        let card = BasicCard(id: UUID().uuidString, prompt: prompt, solution: solution, creationDate: .now, dueDate: .now, nextDueDateMultiplier: 0.01)
        self.addBasicCardToDeck(card, deck)
    }
    
    /// Try to add the card to the deck into the Core Data store.
    func addBasicCardToDeck(_ card: BasicCard, _ deck: Deck) {
        do { try store.insertBasicCard(card, deck) }
        catch { showErrorAlert("Error", "Sorry, there was an error adding to the deck.") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let deck = deck
        else { return }
        
        deckLabel.text = "Deck: \(deck.title)"
    }
}
