import UIKit

class CardSearchViewController: UIViewController {
    let store = CoreDataStore()
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    var cards: [Card] = [] // the collection of cards will be displayed
    
    /** Gets the matched cards from the store and updates the table with the cards. */
    func getMatchedCardsFromStore(_ searchTerms: String) {
        do {
            cards = try store.searchCards(searchTerms)
            //DispatchQueue.main.async { self.cardCollectionView.reloadData() } // TODO: do we need this?
        } catch {
            showErrorAlert("Error", "Sorry, there was an error retrieving the cards.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        // get the decks to display them in the collection view
        // TODO: hardcoded currently
        getMatchedCardsFromStore("hello")
    }
}

extension CardSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /** Returns 2 times the number of cards in the cards array, since we want to show the prompt in one cell, and the solution in another.
     * Therefore, we need two cells for every card. */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count * 2
    }
    
    /// Show the cell's contents in the collection
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCardCell", for: indexPath) as? CustomCardCell
        else { fatalError("Failed to display the card cells.") }
        
        if (indexPath.item % 2 == 0) {
            cell.cellLabel.text = cards[indexPath.item / 2].prompt
        } else {
            cell.cellLabel.text = cards[indexPath.item / 2].solution
        }
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        
        return cell
    }
    
    /// Determines the number of rows and columns within the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let COLLECTION_NUM_ROWS: CGFloat = 5
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
    
    // TODO: test if this is needed
    //override func awakeFromNib() { super.awakeFromNib() }
}
