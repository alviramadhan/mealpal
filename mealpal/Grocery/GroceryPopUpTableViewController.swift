//
//  GroceryPopUpTableViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 17/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class GroceryPopUpTableViewController: UITableViewController {

    var onSave: ((String) -> Void)?
    var inputRowsCount: Int = 1
    var inputTexts: [String] = [""]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // input fields + add‐button row + action row
        return inputRowsCount + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < inputRowsCount {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryAddCell", for: indexPath) as! GroceryAddCell
            cell.GroceryInputTextfield.text = inputTexts[indexPath.row]
            cell.onTextChanged = { [weak self] newText in
                self?.inputTexts[indexPath.row] = newText
            }
            // Configure delete button for this row
            cell.onDeleteTapped = { [weak self] in
                guard let self = self else { return }
                // update model
                self.inputRowsCount -= 1
                self.inputTexts.remove(at: indexPath.row)
                // animate deletion
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            return cell
        } else if indexPath.row == inputRowsCount {
            // dequeue your custom subclass
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryAddRowCell", for: indexPath) as! GroceryAddRowTableViewCell
            // when the add‐button inside that cell is tapped,
            cell.onAddTapped = { [weak self] in
                guard let self = self else { return }
                // insert another text‐field row above the add‐row
                self.tableView.beginUpdates()
                self.inputRowsCount += 1
                self.inputTexts.append("")
                let insertPath = IndexPath(row: self.inputRowsCount - 1, section: indexPath.section)
                self.tableView.insertRows(at: [insertPath], with: .automatic)
                self.tableView.endUpdates()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryActionCell", for: indexPath) as! GroceryActionCell
            cell.onSaveTapped = { [weak self] in
                guard let self = self else { return }
                let texts = self.inputTexts.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                guard !texts.isEmpty else { return }

                guard let uid = Auth.auth().currentUser?.uid else { return }
                let db = Firestore.firestore()

                for text in texts {
                    let groceryData: [String: Any] = ["name": text, "userId": uid]
                    db.collection("groceryItems").addDocument(data: groceryData)
                }

                self.dismiss(animated: true)
            }
            cell.onCancelTapped = { [weak self] in
                self?.dismiss(animated: true)
            }
            return cell
        }
    }
}
