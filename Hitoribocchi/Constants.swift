/// Holds constants that are used throughout the project.
struct Constants {
    /// Used to represent the correct solution for a true/false question card.
    static let TRUE_STRING = "True"
    
    /// Used to represent the correct solution for a true/false question card.
    static let FALSE_STRING = "False"
    
    /// The options value for true/false cards, i.e. "True | False".
    static let TRUE_FALSE_OPTIONS = "\(TRUE_STRING) | \(FALSE_STRING)"
    
    /// The due date multiplier that new cards are initialized with.
    static let NEW_CARD_DUE_DATE_MULTIPLIER = 0.10
    
    /// Sets the card's due date interval to 20% of its orignal value when clicking "Retry".
    static let RETRY_DUE_DATE_MULTIPLIER_FACTOR = 0.20
    
    /// Sets the card's due date interval to 80% of its orignal value when clicking "Hard".
    static let HARD_DUE_DATE_MULTIPLIER_FACTOR = 0.80
    
    /// Sets the card's due date interval to 130% of its original value when clicking "Okay".
    static let OKAY_DUE_DATE_MULTIPLIER_FACTOR = 1.30
    
    /// Sets the card's due date interval to 170% of its original value when clicking "Easy".
    static let EASY_DUE_DATE_MULTIPLIER_FACTOR = 1.70
    
    /// Increases the card's due date interval by 30% when clicking "Okay".
    static let OKAY_DUE_DATE_MULTIPLIER_INCREMENT = 0.30
    
    /// Increases the card's due date interval by 100% when clicking "Easy".
    static let EASY_DUE_DATE_MULTIPLIER_INCREMENT = 1.00
    
    /// How many minutes (before applying the due date multiplier) until the card is due again after pressing "Retry".
    static let RETRY_BASE_MINUTES_UNTIL_DUE_DATE = 0.0
    
    /// How many minutes (before applying the due date multiplier) until the card is due again after pressing "Hard".
    static let HARD_BASE_MINUTES_UNTIL_DUE_DATE = 20.0
    
    /// How many minutes (before applying the due date multiplier) until the card is due again after pressing "Okay".
    static let OKAY_BASE_MINUTES_UNTIL_DUE_DATE = 100.0
    
    /// How many minutes (before applying the due date multiplier) until the card is due again after pressing "Easy".
    static let EASY_BASE_MINUTES_UNTIL_DUE_DATE = 300.0
}
