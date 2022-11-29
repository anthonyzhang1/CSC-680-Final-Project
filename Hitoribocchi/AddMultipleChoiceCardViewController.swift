import UIKit

class AddMultipleChoiceViewController: UIViewController {
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var promptInput: UITextField!
    @IBOutlet weak var optionsInput: UITextField!
    @IBOutlet weak var solutionInput: UITextField!
    
    @IBAction func addCardButtonClicked(_ sender: UIButton) {
        guard let prompt = promptInput.text,
              let solution = solutionInput.text,
              let options = optionsInput.text,
              let deck = deck
        else { return }
        
        // Split the options into an array of options for input validation
        let splitOptions = options.split(separator: "|").map({$0.trimmingCharacters(in: .whitespaces)})
        
        if splitOptions.count > 4 { // Only 4 multiple choice options allowed
            showErrorAlert("Error", "Multiple choice cards can have at most 4 options, i.e. 3 '|' characters.")
            return
        } else if !splitOptions.map({String($0)}).contains(solution) { // the solution must be one of the provided options
            showErrorAlert("Error", "The solution must be one of the multiple choice options.")
            return
        }
        
        let card = MultipleChoiceCard(id: UUID().uuidString, prompt: prompt, solution: solution, creationDate: .now, dueDate: .now, nextDueDateMultiplier: 0.01, options: options)
        self.addMultipleChoiceCardToDeck(card, deck)
    }
    
    /// Try to add the card to the deck into the Core Data store. Clear the input fields on success.
    func addMultipleChoiceCardToDeck(_ card: MultipleChoiceCard, _ deck: Deck) {
        do {
            try store.insertMultipleChoiceCard(card, deck)
            promptInput.text = ""
            solutionInput.text = ""
            optionsInput.text = ""
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
