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
        
        switch (sender.tag) {
        case Constants.RETRY_BUTTON_TAG: // retry button clicked
            guard let newDueDate = calendar.date(byAdding: .minute, value: Int(currentCard.nextDueDateMultiplier * Constants.RETRY_BASE_MINUTES_UNTIL_DUE_DATE), to: .now)
            else { return }
            
            // TODO
            print("retry mins until next:", Int(currentCard.nextDueDateMultiplier * Constants.RETRY_BASE_MINUTES_UNTIL_DUE_DATE))
            print("retry new due date:", newDueDate)
            
            currentCard.dueDate = newDueDate
            currentCard.nextDueDateMultiplier = getNewDueDateMultiplier(oldMultiplier: currentCard.nextDueDateMultiplier, multiplierFactor: Constants.RETRY_DUE_DATE_MULTIPLIER_FACTOR, multiplierIncrement: 0)
            
            updateCardAndAdvance(currentCard)
            break
            
        case Constants.HARD_BUTTON_TAG: // hard button clicked
            guard let newDueDate = calendar.date(byAdding: .minute, value: Int(currentCard.nextDueDateMultiplier * Constants.HARD_BASE_MINUTES_UNTIL_DUE_DATE), to: .now)
            else { return }
            
            // TODO
            print("hard mins until next:", Int(currentCard.nextDueDateMultiplier * Constants.HARD_BASE_MINUTES_UNTIL_DUE_DATE))
            print("hard new due date:", newDueDate)
            
            currentCard.dueDate = newDueDate
            currentCard.nextDueDateMultiplier = getNewDueDateMultiplier(oldMultiplier: currentCard.nextDueDateMultiplier, multiplierFactor: Constants.HARD_DUE_DATE_MULTIPLIER_FACTOR, multiplierIncrement: 0)
            
            updateCardAndAdvance(currentCard)
            break
            
        case Constants.OKAY_BUTTON_TAG: // okay button clicked
            guard let newDueDate = calendar.date(byAdding: .minute, value: Int(currentCard.nextDueDateMultiplier * Constants.OKAY_BASE_MINUTES_UNTIL_DUE_DATE), to: .now)
            else { return }
            
            // TODO
            print("okay mins until next:", Int(currentCard.nextDueDateMultiplier * Constants.OKAY_BASE_MINUTES_UNTIL_DUE_DATE))
            print("okay new due date:", newDueDate)
            
            currentCard.dueDate = newDueDate
            currentCard.nextDueDateMultiplier = getNewDueDateMultiplier(oldMultiplier: currentCard.nextDueDateMultiplier, multiplierFactor: Constants.OKAY_DUE_DATE_MULTIPLIER_FACTOR, multiplierIncrement: Constants.OKAY_DUE_DATE_MULTIPLIER_INCREMENT)
            
            updateCardAndAdvance(currentCard)
            break
            
        case Constants.EASY_BUTTON_TAG:
            guard let newDueDate = calendar.date(byAdding: .minute, value: Int(currentCard.nextDueDateMultiplier * Constants.EASY_BASE_MINUTES_UNTIL_DUE_DATE), to: .now)
            else { return }
            
            // TODO
            print("easy mins until next:", Int(currentCard.nextDueDateMultiplier * Constants.EASY_BASE_MINUTES_UNTIL_DUE_DATE))
            print("easy new due date:", newDueDate)
            
            currentCard.dueDate = newDueDate
            currentCard.nextDueDateMultiplier = getNewDueDateMultiplier(oldMultiplier: currentCard.nextDueDateMultiplier, multiplierFactor: Constants.EASY_DUE_DATE_MULTIPLIER_FACTOR, multiplierIncrement: Constants.EASY_DUE_DATE_MULTIPLIER_INCREMENT)
            
            updateCardAndAdvance(currentCard)
            break
            
        default:
            showErrorAlert("Error", "Sorry, there was an error updating your card.")
        }
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
            solutionOptionsLabel.text = currentCard.solution
            basicCardView.isHidden = false
            
            /* Sets the buttons' text so that it shows how long until the current card will be due if that button was pressed. */
            retryButton.setTitle("Retry\n\(getTimeUntilCardDueAsString(Int(currentCard.nextDueDateMultiplier * Constants.RETRY_BASE_MINUTES_UNTIL_DUE_DATE)))", for: .normal)
            
            hardButton.setTitle("Hard\n\(getTimeUntilCardDueAsString(Int(currentCard.nextDueDateMultiplier * Constants.HARD_BASE_MINUTES_UNTIL_DUE_DATE)))", for: .normal)
            
            okayButton.setTitle("Okay\n\(getTimeUntilCardDueAsString(Int(currentCard.nextDueDateMultiplier * Constants.OKAY_BASE_MINUTES_UNTIL_DUE_DATE)))", for: .normal)
            
            easyButton.setTitle("Easy\n\(getTimeUntilCardDueAsString(Int(currentCard.nextDueDateMultiplier * Constants.EASY_BASE_MINUTES_UNTIL_DUE_DATE)))", for: .normal)
        } else if let currentCard = currentCard as? MultipleChoiceCard {
            print(currentCard) // TODO
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
    
    /// Gets a string representing how long it will take for a card to be due again, e.g. 20 m, 18 h, or 3 d
    func getTimeUntilCardDueAsString(_ minutesUntilDue: Int) -> String {
        if minutesUntilDue < 1 { // < 1 min until due
            return "< 1 m"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_HOUR { // 1-59 mins until due
            return "\(minutesUntilDue) m"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_DAY { // 1-23 hours until due
            return "\(minutesUntilDue / Constants.MINUTES_IN_ONE_HOUR) h"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_MONTH { // 1-29 days until due
            return "\(minutesUntilDue / Constants.MINUTES_IN_ONE_DAY) d"
        } else if minutesUntilDue < Constants.MINUTES_IN_ONE_YEAR { // 1-11 months until due
            return "\(minutesUntilDue / Constants.MINUTES_IN_ONE_MONTH) mo"
        } else { // 1+ years until due
            return "\(minutesUntilDue / Constants.MINUTES_IN_ONE_YEAR) y"
        }
    }
    
    /// Gets the new due date multiplier for a card. The returned double will always be positive.
    func getNewDueDateMultiplier(oldMultiplier: Double, multiplierFactor: Double, multiplierIncrement: Double) -> Double {
        let newMultiplier = (oldMultiplier * multiplierFactor) + multiplierIncrement
        return newMultiplier >= 0.01 ? newMultiplier : 0.01
    }
    
    func updateCardAndAdvance(_ card: Card) {
        do { // update the card's due date in the store and proceed to the next card
            try store.updateCardDueDate(card)
            currentCardIndex += 1
            
            if currentCardIndex >= dueCards.count {
                print("End of deck. Deck refreshed.") // TODO
                // refresh the deck after reaching the end of the due cards
                getDueCardsFromDeck()
                currentCardIndex = 0
            }
            
            displayCurrentCard()
            return

        } catch {
            showErrorAlert("Error", "Sorry, there was an error updating your card.")
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

        // Ensure that the card index will not be out of bounds
        if (currentCardIndex >= dueCards.count) {
            promptLabel.text = """
            No cards are due yet.

            You can add more cards to this deck by pressing the + button above!
            """
            
            solutionOptionsLabel.isHidden = true
            seperatorBar.isHidden = true
            return
        }
        
        /// The current card being displayed to the user.
        let currentCard = dueCards[currentCardIndex]
        
        if currentCard is BasicCard { // Handle the display for a basic card
            promptLabel.text = currentCard.prompt
            solutionOptionsLabel.isHidden = true
            seperatorBar.isHidden = true
        } else if currentCard is MultipleChoiceCard { // handle multiple choice card display
            promptLabel.text = currentCard.prompt
        }
    }
}
