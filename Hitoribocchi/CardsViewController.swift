import UIKit

class CardsViewController: UIViewController {
    let calendar = Calendar.current // used to calculate the new due dates after answering a card
    let store = CoreDataStore()
    var deck: Deck? // retrieved from the sender
    var dueCards: [Card] = [] // retrieved from the store and displayed to the user
    /// The index of the currently shown card.
    var currentCardIndex = 0
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var seperatorBar: UIView!
    @IBOutlet weak var solutionOptionsLabel: UILabel!
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    
    /// Used to hide/show the basic card response buttons.
    @IBOutlet weak var basicCardView: UIView!
    
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
        // handle the case where there is no card being shown, therefore there is no card to delete
        if currentCardIndex >= dueCards.count {
            let alert = UIAlertController(title: "There is no card to delete.", message: "You need to be viewing a card in order to delete it.", preferredStyle: .alert)
            
            // Add the OK button to the alert box
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            // Show the alert, and return so that we do not execute the rest of the function
            present(alert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Delete Current Card", message: "Are you sure you want to delete this card?", preferredStyle: .alert)
            
        // Add the cancel button to the alert box
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add the delete button to the alert box. When it is clicked, try to delete the currently shown card. The deck is refreshed to update the deck's cards.
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            do {
                try self.store.deleteCard(self.dueCards[self.currentCardIndex])
                self.getDueCardsFromDeck()
                self.displayCurrentCard()
            } catch {
                self.showErrorAlert("Error", "Sorry, there was an error deleting the card.")
            }
        })
        
        // show the alert
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func viewDetailsButtonClicked(_ sender: UIBarButtonItem) {
        // handle the case where there is no card being shown, therefore there is no card to view
        if currentCardIndex >= dueCards.count {
            let alert = UIAlertController(title: "There is no card to view the details of.", message: "You need to be viewing a card in order to view its details.", preferredStyle: .alert)
            
            // Add the OK button to the alert box
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            // Show the alert, and return so that we do not execute the rest of the function
            present(alert, animated: true, completion: nil)
            return
        }

        performSegue(withIdentifier: "cardsToCardDetailsSegue", sender: sender)
    }
    
    @IBAction func basicCardButtonClicked(_ sender: UIButton) {

        /// The current card being displayed to the user.
        var currentCard = dueCards[currentCardIndex]
        /// The new due date of the card.
        var newDueDate: Date?
        
        newDueDate = calendar.date(byAdding: .minute, value: 1, to: .now)
        //getTimeUntilCardDueAsString
        
        switch (sender.tag) {
        case 0:
            print("retry")
            
            currentCard.dueDate = .now
            
            break
        case 1:
            print("hard")
            break
        case 2:
            print("okay")
            break
        case 3:
            print("easy")
            break
        default:
            print("Error")
        }
    }
    
    func calculateNextDueDate(card: Card) {
        
    }

    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        // make sure that we do not get an out of bounds error
        guard currentCardIndex < dueCards.count
        else { return }
        
        /// The current card being displayed to the user.
        let currentCard = dueCards[currentCardIndex]
        
        if currentCard is BasicCard {  // Handle the on click display for a basic card
            seperatorBar.isHidden = false
            solutionOptionsLabel.isHidden = false
            basicCardView.isHidden = false
            solutionOptionsLabel.text = currentCard.solution
            
            print(currentCard.nextDueDateMultiplier * Constants.RETRY_BASE_MINUTES_UNTIL_DUE_DATE)
            retryButton.setTitle("Retry\n22d", for: .normal)
        } else if let currentCard = currentCard as? MultipleChoiceCard {
            
        }
    }
    
    /// Sends the deck to one of the Add Card windows, depending on which option the user pressed.
    /// Or, segue to the view card details page if the View Details button was pressed.
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
        } else if segue.identifier == "cardsToCardDetailsSegue" { // view details segue
            if let cardDetailsViewController = segue.destination as? CardDetailsViewController
            { cardDetailsViewController.currentCard = dueCards[currentCardIndex] }
        }
    }
    
    /// Gets a string representing how long it will take for a card to be due again, e.g. 20 min, 18 hr, or 3 d
    func getTimeUntilCardDueAsString(_ minutesUntilDue: Double) -> String {
        if minutesUntilDue < 1 { // < 1 mins until due
            return "< 1 min"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_HOUR { // 1-59 mins until due
            return "\(minutesUntilDue) min"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_DAY { // 1-23 hours until due
            return "\(Int(floor(minutesUntilDue / Constants.MINUTES_IN_ONE_HOUR))) hr"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_MONTH { // 1-29 days until due
            return "\(Int(floor(minutesUntilDue / Constants.MINUTES_IN_ONE_DAY))) d"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_YEAR { // 1-11 months until due
            return "\(Int(floor(minutesUntilDue / Constants.MINUTES_IN_ONE_MONTH))) mo"
        } else { // 1+ years until due
            return "\(Int(floor(minutesUntilDue / Constants.MINUTES_IN_ONE_YEAR))) yr"
        }
    }
    
    /// Gets the cards from the store and fill the `dueCards` array with the retrieved cards. Shuffle the deck.
    func getDueCardsFromDeck() {
        guard let deck = deck
        else { return }
        
        do {
            dueCards = try store.getDueCardsFromDeck(deck)
            dueCards = dueCards.shuffled()
        } catch {
            showErrorAlert("Error", "Sorry, there was an error retrieving the cards.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // get the due cards to display on the screen after shuffling them
        // need to get due cards in case user made a new card and went back to the card view
        getDueCardsFromDeck()
        promptLabel.isHidden = false
        solutionOptionsLabel.isHidden = true
        displayCurrentCard()
    }
    
    func displayCurrentCard() {
        // Do not show the separator bar if the solution is not shown
        if solutionOptionsLabel.isHidden { seperatorBar.isHidden = true }
        basicCardView.isHidden = true

        // Ensure there are due cards in the array
        guard currentCardIndex < dueCards.count
        else {
            promptLabel.text = """
            No cards are due yet.

            You can add more cards to this deck by pressing the + button above!
            """
            
            return
        }
        
        /// The current card being displayed to the user.
        let currentCard = dueCards[currentCardIndex]
        
        if currentCard is BasicCard { // Handle the display for a basic card
            promptLabel.text = currentCard.prompt
        } else if currentCard is MultipleChoiceCard { // handle multiple choice card display
            promptLabel.text = currentCard.prompt
        }
    }
}
