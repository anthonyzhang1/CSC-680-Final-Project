import UIKit

class CardSearchViewController: UIViewController {
    /// The maximum number of cards returned in each Card entity when searching. The actual number of results can be up to N times greater than this value, where N is the number of card entities that exist.
    let SEARCH_FETCH_LIMIT = 50
    
    let store = CoreDataStore()
    var cards: [Card] = [] // the cards to display
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cardTableView: UITableView!
    
    /// Get the most recently created cards.
    func getRecentCards() {
        do { cards = try store.getAllCards(SEARCH_FETCH_LIMIT) }
        catch { showErrorAlert("Error", "Sorry, there was an error fetching the cards.") }
    }
    
    /// Try to delete the selected card.
    func deleteCard(_ card: Card) {
        do {
            try store.deleteCard(card)
            searchBarSearchButtonClicked(searchBar) // update the table so that the deleted cards disappears
        } catch {
            showErrorAlert("Error", "Sorry, there was an error deleting the card.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        cardTableView.delegate = self
        cardTableView.dataSource = self
        
        getRecentCards()
    }
}

extension CardSearchViewController: UISearchBarDelegate {
    /** Executes the search when the user presses Return.
        Gets the matched cards from the store and updates the table with the cards. The maximum number of cards returned per entity is determined by `limit`. */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerms = searchBar.text
        else { return }
        
        do {
            cards = try store.searchCards(searchTerms, SEARCH_FETCH_LIMIT)
            DispatchQueue.main.async { self.cardTableView.reloadData() }
        } catch {
            showErrorAlert("Error", "Sorry, there was an error retrieving the cards.")
        }
    }
}

extension CardSearchViewController: UITableViewDelegate, UITableViewDataSource {
    /// Returns the number of cards in the cards array.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return cards.count }
    
    /// Loads the table cell's contents.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cards[indexPath.row].prompt
        
        return cell
    }
    
    /// Called when selecting a table cell. Takes the user to the card View Controller.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewCardDetailsSegue", sender: indexPath)
        
        // deselect the row after we transition to the new screen
        cardTableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Called when swiping on a table cell. Allows the user to delete the card.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { deleteCard(cards[indexPath.row]) }
    }
}
