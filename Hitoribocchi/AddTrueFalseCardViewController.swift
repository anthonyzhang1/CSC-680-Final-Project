import UIKit

class AddTrueFalseCardViewController: UIViewController {
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var promptInput: UITextField!
    @IBOutlet weak var trueFalseSegmentedControl: UISegmentedControl!
    
    @IBAction func addCardButtonClicked(_ sender: UIButton) {
        guard let prompt = promptInput.text,
              let deck = deck
        else { return }
        
        /// Gets the string in the segmented control's selection
        let solutionString = trueFalseSegmentedControl.selectedSegmentIndex == 1 ? Constants.TRUE_STRING : Constants.FALSE_STRING
        
        let card = MultipleChoiceCard(id: UUID().uuidString, prompt: prompt, solution: solutionString, creationDate: .now, dueDate: .now, nextDueDateMultiplier: 0.01, options: "\(Constants.TRUE_STRING) | \(Constants.FALSE_STRING)")
        self.addMultipleChoiceCardToDeck(card, deck)
    }
    
    /// Try to add the card to the deck into the Core Data store. Clear the input fields on success.
    func addMultipleChoiceCardToDeck(_ card: MultipleChoiceCard, _ deck: Deck) {
        do {
            try store.insertMultipleChoiceCard(card, deck)
            promptInput.text = ""
        } catch {
            showErrorAlert("Error", "Sorry, there was an error adding to the deck.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let deck = deck
        else { return }
        
        deckLabel.text = "Deck: \(deck.title)"
    }
}
