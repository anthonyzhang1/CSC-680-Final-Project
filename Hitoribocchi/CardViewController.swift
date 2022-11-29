import UIKit

class CardViewController: UIViewController {
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    var dueCards: [Card] = [] // retrieved from the store and displayed to the user
    /// The index of the currently shown card.
    var currentCardIndex = 0
    
    /// Show an action sheet prompting the user what type of flashcard to add when they click the Add button.
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let prompt = UIAlertController(title: "Select the type of flashcard to add.", message: nil, preferredStyle: .actionSheet)
        
        // Add the Basic Flashcard option
        prompt.addAction(UIAlertAction(title: "Basic", style: .default) { _ in
            self.performSegue(withIdentifier: "addBasicCardSegue", sender: sender)
        })
        
        // Add the True/False Flashcard option
        prompt.addAction(UIAlertAction(title: "True / False", style: .default) { _ in
            self.performSegue(withIdentifier: "addTrueFalseCardSegue", sender: sender)
        })
        
        // Add the Multiple Choice Flashcard option
        prompt.addAction(UIAlertAction(title: "Multiple Choice", style: .default) { _ in
            self.performSegue(withIdentifier: "addMultipleChoiceCardSegue", sender: sender)
        })
        
        // Add the Cancel option
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // show the alert
        present(prompt, animated: true, completion: nil)
    }
    
    /// Show an alert prompting the user if they want to actually delete the card.
    @IBAction func deleteButtonClicked(_ sender: UIBarButtonItem) {
        if dueCards.isEmpty { // handle the case where there is no card being shown, therefore there is no card to delete
            let alert = UIAlertController(title: "There is no card to delete!", message: nil, preferredStyle: .alert)
            
            // Add the OK button to the alert box
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            // Show the alert, and return so that we do not execute the rest of the function
            present(alert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Delete Current Card", message: "Are you sure you want to delete this card?", preferredStyle: .alert)
            
        // Add the cancel button to the alert box
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add the delete button to the alert box. When it is clicked, delete the currently shown card.
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("currently shown card:", self.dueCards[self.currentCardIndex])
            self.deleteCurrentlyShownCard(self.dueCards[self.currentCardIndex])
        })
        
        // show the alert
        present(alert, animated: true, completion: nil)

    }
    
    /// Sends the deck to one of the Add Card windows, depending on which option the user pressed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBasicCardSegue" { // add basic cards
            if let addCardViewController = segue.destination as? AddBasicCardViewController,
               let deck = deck
            { addCardViewController.deck = deck }
        } else if segue.identifier == "addTrueFalseCardSegue" { // add true/false cards
            if let addCardViewController = segue.destination as? AddTrueFalseCardViewController,
               let deck = deck
            { addCardViewController.deck = deck }
        } else if segue.identifier == "addMultipleChoiceCardSegue" { // add multiple choice cards
            if let addCardViewController = segue.destination as? AddMultipleChoiceViewController,
               let deck = deck
            { addCardViewController.deck = deck }
        }
    }
    
    /// Gets the cards from the store and fill the `cards` array with the retrieved cards.
    func getDueCardsFromDeck() {
        guard let deck = deck
        else { return }
        
        do { dueCards = try store.getDueCardsFromDeck(deck) }
        catch { showErrorAlert("Error", "Sorry, there was an error retrieving the cards.") }
    }
    
    /// Try to delete the currently shown card.
    func deleteCurrentlyShownCard(_ card: Card) {
        do {
            try store.deleteCard(card)
            getDueCardsFromDeck()
            dueCards = dueCards.shuffled()
            print("card deleted") // TODO
        } catch {
            showErrorAlert("Error", "Sorry, there was an error deleting the card.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the due cards to display on the screen after shuffling them
        getDueCardsFromDeck()
        dueCards = dueCards.shuffled()
        
        // TODO: debug
        for card in dueCards {
            print("Card:", card)
        }
    }
}
