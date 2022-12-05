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
        
        let card = BasicCard(id: UUID().uuidString, prompt: prompt, solution: solution, creationDate: .now, dueDate: .now, nextDueDateMultiplier: Constants.NEW_CARD_DUE_DATE_MULTIPLIER)
        
        do { // Try to add the card to the deck into the Core Data store. Clear the input fields on success.
            try store.insertBasicCard(card, deck)
            promptInput.text = ""
            solutionInput.text = ""
        } catch {
            showErrorAlert("Error", "Sorry, there was an error adding to the deck.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let deck = deck { deckLabel.text = "Deck: \(deck.title)" }
        else { return }
    }
}
