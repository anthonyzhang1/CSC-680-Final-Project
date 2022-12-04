import UIKit

class CardDetailsViewController: UIViewController {
    let store = CoreDataStore()
    var currentCard: Card? // retrieved from the sender
    
    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var cardTypeLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var optionsSolutionLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var dueOnLabel: UILabel!
    @IBOutlet weak var dueDateMultiplierLabel: UILabel!
    
    /// Show an alert prompting the user if they want to actually delete the card.
    @IBAction func deleteButtonClicked(_ sender: UIBarButtonItem) {
        guard let currentCard = currentCard
        else { return }
        
        let alert = UIAlertController(title: "Delete Current Card", message: "Are you sure you want to delete this card?", preferredStyle: .alert)
        
        // Add the cancel button to the alert box
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add the delete button to the alert box. When it is clicked, delete the currently shown card, and go back to the card search view.
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            do { try self.store.deleteCard(currentCard) }
            catch { self.showErrorAlert("Error", "Sorry, there was an error deleting the card.") }
            
            self.navigationController?.popViewController(animated: true)
        })
        
        // show the alert
        present(alert, animated: true, completion: nil)
    }
    
    /// Display the card's details. What is displayed depends on the card's type, e.g. basic vs. multiple choice cards.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentCard = currentCard
        else { return }
        
        do { // get the name of the card's deck
            deckLabel.text = try "Deck: \(store.getACardsDeckTitle(fromCard: currentCard))"
        } catch {
            self.showErrorAlert("Error", "Sorry, there was an error getting the deck's title.")
            return
        }
        
        /* Display the type of the current card, e.g. true/false. */
        if currentCard is BasicCard { // basic card type
            cardTypeLabel.text = "Type: Basic"
        } else if let multipleChoiceCard = currentCard as? MultipleChoiceCard { // can be true/false or multiple choice
            if multipleChoiceCard.options == Constants.TRUE_FALSE_OPTIONS { // true/false card type
                cardTypeLabel.text = "Type: True/False"
            } else { // multiple choice card type
                cardTypeLabel.text = "Type: Multiple Choice"
            }
        }
        
        cardIdLabel.text = "Card ID:\n\(currentCard.id)"
        promptLabel.text = "Prompt:\n\(currentCard.prompt)"
        
        /* Display the current card's solution and multiple choice options, if there are any */
        if currentCard is BasicCard { // basic card
            optionsSolutionLabel.text = "Solution:\n\(currentCard.solution)"
        } else if let multipleChoiceCard = currentCard as? MultipleChoiceCard {
            if multipleChoiceCard.options == Constants.TRUE_FALSE_OPTIONS { // true/false card
                optionsSolutionLabel.text = "Solution:\n\(multipleChoiceCard.solution)"
            } else { // multiple choice card
                optionsSolutionLabel.text = """
                Options:
                \(multipleChoiceCard.options)
                
                Solution:
                \(multipleChoiceCard.solution)
                """
            }
        }
        
        /// Formats the dates in a human-readable format.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss" // e.g. 2022-09-18, 18:32:10
        
        createdOnLabel.text = "Creation Date:\n\(dateFormatter.string(from: currentCard.creationDate))"
        
        /* Display the current card's due date, and indicate as such if it is due. */
        if .now >= currentCard.dueDate { // if the current card is due
            dueOnLabel.text = "Due Date:\n\(dateFormatter.string(from: currentCard.dueDate)) (card is due)"
        } else { // not due yet
            dueOnLabel.text = "Due Date:\n\(dateFormatter.string(from: currentCard.dueDate))"
        }
        
        dueDateMultiplierLabel.text = "Due Date Multiplier:\nx\(currentCard.nextDueDateMultiplier)"
    }
}
