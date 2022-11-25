import UIKit

class ViewController: UIViewController {
    let store = CoreDataStore()
    
    @IBOutlet weak var deckTableView: UITableView!
    var decks: [Deck] = [] // will be displayed in the table

    /** Gets the decks from the CoreData store and fill the `decks` array with the retrieved decks.
      * Updates the table with the decks in case any were added since displaying the view. */
    func getDecksFromStore() {
        do {
            decks = try store.getAllDecks()
            DispatchQueue.main.async { self.deckTableView.reloadData() }
        } catch {
            showErrorAlert("Error", "Sorry, there was an error retrieving the decks.")
        }
    }
    
    /// Show the add deck alert prompt when the add deck button is pressed.
    @IBAction func showAddDeckAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Deck", message: nil, preferredStyle: .alert)
        
        // Add the add deck button to the alert box
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let title = alert.textFields?.first?.text
            else { return }
            
            // autogenerate the id with UUID and take the title from the user's input
            let deck = Deck(id: UUID().uuidString, title: title)
            self.addDeckToStore(deck)
        })
        
        // Add the cancel button to the alert box
        alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler: nil))
        
        // Add the textfield asking for the deck's title to the alert box
        alert.addTextField { textField in
            textField.placeholder = "Deck Title"
        }
        
        // show the alert
        present(alert, animated: true, completion: nil)
    }
    
    /// Try to add the deck in the argument to the CoreData store. Refresh the table on success.
    func addDeckToStore(_ deck: Deck) {
        do {
            try store.insertDeck(deck)
            getDecksFromStore()
        } catch {
            showErrorAlert("Error", "Sorry, there was an error adding the deck.")
        }
    }
    
    /// Try to delete the deck in the argument from the CoreData store. Refresh the table on success.
    func removeDeckFromStore(_ deck: Deck) {
        do {
            try store.deleteDeck(deck)
            getDecksFromStore()
        } catch {
            showErrorAlert("Error", "Sorry, there was an error deleting the deck.")
        }
    }
    
    /// Shows an alert with the specified `title` and `message` parameters.
    func showErrorAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // add OK button to the error
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deckTableView.delegate = self
        deckTableView.dataSource = self
        
        // get the decks to display them in the table
        getDecksFromStore()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    /// Returns the number of rows in the deck table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = decks[indexPath.row].title

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deck = decks[indexPath.row]
        print("tbview deck:", deck) // TODO
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("remove deck:", decks[indexPath.row]) // TODO
            removeDeckFromStore(decks[indexPath.row])
        }
    }
}
