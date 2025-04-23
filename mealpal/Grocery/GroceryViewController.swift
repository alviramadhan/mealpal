//
//  GroceryViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit
import FirebaseAuth

class GroceryViewController: UITableViewController {
    
    @IBOutlet weak var GroceryAddButton: UIBarButtonItem!
    var groceryItems: [GroceryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        fetchGroceryItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroceryItems()
    }

    func fetchGroceryItems() {
        GroceryRepository.shared.fetchItems { items in
            self.groceryItems = items
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItems.count + 1 //for title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryTitleCell") as! GroceryItemCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryItemCell", for: indexPath) as! GroceryItemCell
            let item = groceryItems[indexPath.row - 1]
            cell.GroceryItemLabel.text = item.name

            // Configure delete action
            cell.onDeleteTapped = { [weak self] in
                guard let self = self else { return }
                let item = self.groceryItems[indexPath.row - 1]
                GroceryRepository.shared.deleteItem(withId: item.id) { error in
                    if let error = error {
                        print("❌ Failed to delete grocery item from Firestore:", error.localizedDescription)
                        return
                    }

                    self.groceryItems.remove(at: indexPath.row - 1)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
            return cell
        }
    }

    // MARK: - Present Pop-up to Add New Items to the Grocery List
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        // Present the GroceryPopUpTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let groceryPopUp = storyboard.instantiateViewController(withIdentifier: "GroceryPopUpTableViewController") as? GroceryPopUpTableViewController else {
            return
        }
        groceryPopUp.onSave = { [weak self] _ in
            // Fetch the updated list of grocery items
            self?.fetchGroceryItems()
        }
        let navigationController = UINavigationController(rootViewController: groceryPopUp)
        present(navigationController, animated: true, completion: nil)
    }
}
