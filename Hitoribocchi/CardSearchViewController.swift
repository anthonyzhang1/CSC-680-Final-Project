import UIKit

class CardSearchViewController: UIViewController {
    let store = CoreDataStore()
    /// The maximum number of cards returned in each Card entity when searching. The actual number of results can be up to 2 times greater than this value, since we have 2 card entities.
    let SEARCH_FETCH_LIMIT = 25

    var cards: [Card] = [] // the collection of cards will be displayed
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var searchTermsInput: UITextField!
    
    /// Search the store for matching prompts when the search button is clicked.
    @IBAction func searchButtonClicked(_ sender: UIButton) {
        guard let searchTerms = searchTermsInput.text
        else { return }
        
        self.getMatchedCardsFromStore(terms: searchTerms, limit: SEARCH_FETCH_LIMIT)
    }
    
    /** Gets the matched cards from the store and updates the table with the cards. The maximum number of cards returned per entity is determined by `limit`. */
    func getMatchedCardsFromStore(terms searchTerms: String, limit entityFetchLimit: Int) {
        do {
            cards = try store.searchCards(searchTerms, entityFetchLimit)
            DispatchQueue.main.async { self.cardCollectionView.reloadData() }
        } catch {
            showErrorAlert("Error", "Sorry, there was an error retrieving the cards.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
    }
}

extension CardSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /** Returns 2 times the number of cards in the cards array, since we want to show the prompt in one cell, and the solution in another.
        Therefore, we need two cells for every card. */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count * 2
    }
    
    /// Show the cell's contents in the collection.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // initialize our custom created cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCardCell", for: indexPath) as? CustomCardCell
        else { fatalError("Failed to display the card cells.") }
        
        // Even index means the left column, so show the prompt. Odd index means the right column, so show the solution.
        if (indexPath.item % 2 == 0) { cell.cellLabel.text = cards[indexPath.item / 2].prompt }
        else { cell.cellLabel.text = cards[indexPath.item / 2].solution }
        
        // Adds the border outline and border color (black) for each cell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        
        return cell
    }
    
    /// Determines the number of rows and columns within the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let COLLECTION_NUM_ROWS: CGFloat = 4
        let COLLECTION_NUM_COLS: CGFloat = 2
        let PADDING: CGFloat = 10
        let collectionViewSize = collectionView.frame.size.width - PADDING
                
        return CGSize(width: collectionViewSize / COLLECTION_NUM_COLS, height: collectionViewSize / COLLECTION_NUM_ROWS)
    }
}

/// The class for the cell in the search collection view.
class CustomCardCell: UICollectionViewCell {
    /// The label inside of the cell.
    @IBOutlet weak var cellLabel: UILabel!
}
