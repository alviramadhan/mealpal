//
//  GroceryViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit
import UIKit


class GroceryViewController: UITableViewController {
    
    @IBOutlet weak var GroceryAddButton: UIBarButtonItem!
    var groceryItems: [GroceryItem] = [
        GroceryItem(name: "Broccoli"),
        GroceryItem(name: "Eggs"),
        GroceryItem(name: "Chicken Breast"),
        GroceryItem(name: "Milk")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
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
                // Update data source
                self.groceryItems.remove(at: indexPath.row - 1)
                // Animate row deletion
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
            return cell
        }
    }
}
