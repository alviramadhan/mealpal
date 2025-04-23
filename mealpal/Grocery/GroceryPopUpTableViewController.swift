//
//  GroceryPopUpTableViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 17/4/2025.

import UIKit
import FirebaseAuth

class GroceryPopUpTableViewController: UITableViewController {
    
    var onSave: ((String) -> Void)?
      var inputRowsCount: Int = 1
      var inputTexts: [String] = [""]
      
      override func viewDidLoad() {
          super.viewDidLoad()
      }
      
      // MARK: - Table view data source
      
      override func numberOfSections(in tableView: UITableView) -> Int {
          return 1
      }
      
      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return inputRowsCount + 2 // input fields + add button row + action row
      }
      
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if indexPath.row < inputRowsCount {
              let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryAddCell", for: indexPath) as! GroceryAddCell
              cell.GroceryInputTextfield.text = inputTexts[indexPath.row]  // Correctly bind the row with the array
              
              // When text changes, update the inputTexts array
              cell.onTextChanged = { [weak self] newText in
                  self?.inputTexts[indexPath.row] = newText
              }
              
              // Configure delete button for this row
              cell.onDeleteTapped = { [weak self] in
                  guard let self = self else { return }
                  self.inputRowsCount -= 1
                  self.inputTexts.remove(at: indexPath.row)
                  tableView.beginUpdates()
                  tableView.deleteRows(at: [indexPath], with: .automatic)
                  tableView.endUpdates()
              }
              return cell
          } else if indexPath.row == inputRowsCount {
              let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryAddRowCell", for: indexPath) as! GroceryAddRowTableViewCell
              cell.onAddTapped = { [weak self] in
                  guard let self = self else { return }
                  self.inputRowsCount += 1
                  self.inputTexts.append("")  // Add an empty text field for the new ingredient
                  let insertPath = IndexPath(row: self.inputRowsCount - 1, section: indexPath.section)
                  self.tableView.insertRows(at: [insertPath], with: .automatic)
              }
              return cell
          } else {
              // Action button row for Save
              let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryActionCell", for: indexPath) as! GroceryActionCell
              cell.onSaveTapped = { [weak self] in
                  guard let self = self else { return }
                  
                  // Debugging print to check if the action is triggered
                  print("Save button clicked!")
                  
                  // Filter out any empty ingredients and trim whitespaces
                  let texts = self.inputTexts.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                  guard !texts.isEmpty else {
                      print("❌ No ingredients to save.")
                      return
                  }  // Only save if there are valid ingredients

                  // Debugging print to check which ingredients are being saved
                  print("Ingredients to save: \(texts)")

                  guard let uid = Auth.auth().currentUser?.uid else { return }
                  // Save the ingredients to Firestore
                  GroceryRepository.shared.addItems(texts, forUser: uid)
                  
                  // Call the onSave closure to notify the parent view controller
                  self.onSave?(texts.joined(separator: ", "))  // Pass ingredients to the parent for reloading
                  
                  // Dismiss the pop-up after saving
                  self.dismiss(animated: true)
              }
              return cell
          }
      }
  }
