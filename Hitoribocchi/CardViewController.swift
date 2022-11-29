import UIKit

class CardViewController: UIViewController {
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    var dueCards: [Card] = [] // retrieved from the store and displayed to the user
    
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
