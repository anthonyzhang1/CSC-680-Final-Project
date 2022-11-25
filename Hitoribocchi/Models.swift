import Foundation

/// A card with the attributes every other card should also have.
protocol Card: Codable {
    /// Should be a UUID.
    var id: String { get }
    var prompt: String { get }
    var creationDate: Date { get }
    var dueDate: Date { get }
    /** Determines when the next due date will be by multiplying some predetermined amount of time with this multiplier.
        Example value: 1.5. */
    var nextDueDateMultiplier: Decimal { get }
}

/// A deck of cards.
struct Deck: Codable {
    /// Should be a UUID.
    let id: String
    let title: String
}

/// A basic card with only a prompt and a solution. The user tells the app whether they were correct or not.
struct BasicCard: Card {
    let id: String
    let prompt: String
    let solution: String
    let creationDate: Date
    let dueDate: Date
    let nextDueDateMultiplier: Decimal
}

/** A card that allows for multiple options, of which only one is correct. This struct includes True or False cards.
    The user will not be able to specify whether they were correct or not; the app determines that,
    based on the user's selection. */
struct MultipleChoiceCard: Card {
    let id: String
    let prompt: String
    /// Will be stored as a string in the store by converting from an array to a string, separated with `|`.
    let options: [String]
    /// Should be an element in `options`.
    let solution: String
    let creationDate: Date
    let dueDate: Date
    let nextDueDateMultiplier: Decimal
}
