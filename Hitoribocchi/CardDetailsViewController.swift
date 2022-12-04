import UIKit

class CardDetailsViewController: UIViewController {
    let store = CoreDataStore()
    var currentCard: Card? // retrieved from the sender
    var deckTitle = "" // retrieved from the store
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentCard = currentCard
        else { return }
        
        print(currentCard)
        
        do {
            deckTitle = try store.getACardsDeckTitle(fromCard: currentCard)
        } catch {
            self.showErrorAlert("Error", "Sorry, there was an error getting the deck's title.")
            return
        }
        
        print(deckTitle)
    }
}
