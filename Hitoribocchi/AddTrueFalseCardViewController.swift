import UIKit

class AddTrueFalseCardViewController: UIViewController {
    /// Used to represent the correct solution for a true/false question card.
    let TRUE_STRING = "True"
    /// Used to represent the correct solution for a true/false question card.
    let FALSE_STRING = "False"
    
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
        let solutionString = trueFalseSegmentedControl.selectedSegmentIndex == 1 ? TRUE_STRING : FALSE_STRING
        
        let card = MultipleChoiceCard(id: UUID().uuidString, prompt: prompt, solution: solutionString, creationDate: .now, dueDate: .now, nextDueDateMultiplier: 0.01, options: "\(TRUE_STRING) | \(FALSE_STRING)")
        self.addMultipleChoiceCardToDeck(card, deck)
    }
    
    /// Try to add the card to the deck into the Core Data store.
    func addMultipleChoiceCardToDeck(_ card: MultipleChoiceCard, _ deck: Deck) {
        do {
            try store.insertMultipleChoiceCard(card, deck)
        } catch {
            showErrorAlert("Error", "Sorry, there was an error adding to the deck.")
            print("Error:", error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let deck = deck
        else { return }
        
        deckLabel.text = "Deck: \(deck.title)"
    }
}
