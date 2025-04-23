//
//  GroceryViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("groceryItems")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.groceryItems = docs.compactMap { doc in
                        let data = doc.data()
                        return GroceryItem(id: doc.documentID, name: data["name"] as? String ?? "")
                    }
                    self.tableView.reloadData()
                }
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
                Firestore.firestore().collection("groceryItems").document(item.id).delete { error in
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
}
