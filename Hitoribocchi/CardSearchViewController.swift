import UIKit

class CardSearchViewController: UIViewController {
    /// The maximum number of cards returned in each Card entity when searching. The actual number of results can be up to N times greater than this value, where N is the number of card entities that exist.
    let SEARCH_FETCH_LIMIT = 50
    
    let store = CoreDataStore()
    var cards: [Card] = [] // the cards to display
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cardTableView: UITableView!
    
    // send the clicked on Card to the new view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cardDetailsViewController = segue.destination as? CardDetailsViewController,
           let cardIndex = cardTableView.indexPathForSelectedRow?.row
        { cardDetailsViewController.currentCard = cards[cardIndex] }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        cardTableView.delegate = self
        cardTableView.dataSource = self
        
        searchBarSearchButtonClicked(searchBar)
    }
    
    override func viewDidAppear(_ animated: Bool) { searchBarSearchButtonClicked(searchBar) }
}

extension CardSearchViewController: UISearchBarDelegate {
    /** Executes the search when the user presses Return.
     Gets the matched cards from the store and updates the table with the cards. The maximum number of cards returned per entity is determined by `limit`. */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerms = searchBar.text
        else { return }
        
        do {
            // If search terms were provided, execute the search. If no search terms were provided, retrieve all recently created cards.
            if (searchTerms.count > 0) { cards = try store.searchCards(searchTerms, SEARCH_FETCH_LIMIT) }
            else { cards = try store.getAllCards(SEARCH_FETCH_LIMIT) }
            
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
        performSegue(withIdentifier: "searchToCardDetailsSegue", sender: indexPath)
        
        // deselect the row after we transition to the new screen
        cardTableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Called when swiping on a table cell. Allows the user to delete the card.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try store.deleteCard(cards[indexPath.row])
                searchBarSearchButtonClicked(searchBar) // update the table so that the deleted cards disappears
            } catch {
                showErrorAlert("Error", "Sorry, there was an error deleting the card.")
            }
        }
    }
}
