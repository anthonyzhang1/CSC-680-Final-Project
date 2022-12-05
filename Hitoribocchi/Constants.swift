/// Holds constants that are used throughout the project.
struct Constants {
    /// Used to represent the correct solution for a true/false question card.
    static let TRUE_STRING = "True"
    
    /// Used to represent the correct solution for a true/false question card.
    static let FALSE_STRING = "False"
    
    /// The options value for true/false cards, i.e. "True | False".
    static let TRUE_FALSE_OPTIONS = "\(TRUE_STRING) | \(FALSE_STRING)"
    
    /// The tag value for the "Retry" button in the Due Cards screen, for basic cards.
    static let RETRY_BUTTON_TAG = 0
    
    /// The tag value for the "Hard" button in the Due Cards screen, for basic cards.
    static let HARD_BUTTON_TAG = 1
    
    /// The tag value for the "Okay" button in the Due Cards screen, for basic cards.
    static let OKAY_BUTTON_TAG = 2
    
    /// The tag value for the "Easy" button in the Due Cards screen, for basic cards.
    static let EASY_BUTTON_TAG = 3

    /// How many seconds there are in a minute.
    static let SECONDS_IN_ONE_MINUTE = 60
    
    /// How many hours there are in a day, roughly. Not used for precise calculations.
    static let HOURS_IN_ONE_DAY = 24
    
    /// How many days there are in a month, roughly. Not used for precise calculations.
    static let DAYS_IN_ONE_MONTH = 30
    
    /// How many months there are in a year.
    static let MONTHS_IN_ONE_YEAR = 12
    
    /// How many minutes there are in an hour.
    static let MINUTES_IN_ONE_HOUR = 60
    
    /// How many minutes there are in a day, roughly. Not used for precise calculations.
    static let MINUTES_IN_ONE_DAY: Int = MINUTES_IN_ONE_HOUR * HOURS_IN_ONE_DAY
    
    /// How many minutes there are in a month, roughly. Not used for precise calculations.
    static let MINUTES_IN_ONE_MONTH: Int = MINUTES_IN_ONE_DAY * DAYS_IN_ONE_MONTH
    
    /// How many minutes there are in a year, roughly. Not used for precise calculations.
    static let MINUTES_IN_ONE_YEAR: Int = MINUTES_IN_ONE_MONTH * MONTHS_IN_ONE_YEAR
    
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
