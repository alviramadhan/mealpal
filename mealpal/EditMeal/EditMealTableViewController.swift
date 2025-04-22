//
//  EditMealTableViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EditMealTableViewController: UITableViewController {
    var mealImage: UIImage?
    var mealName: String = ""
    var ingredients: [String] = []

   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Image, Name, Ingredients, Add Row, Save Button
        return ingredients.count + 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Image cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMealImageTableViewCell", for: indexPath) as! EditMealImageTableViewCell
            cell.mealImageView.image = mealImage
            return cell
        } else if indexPath.row == 1 {
            // Name cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMealNameTableViewCell", for: indexPath) as! EditMealNameTableViewCell
            cell.mealNameTextField.text = mealName
            return cell
        } else if indexPath.row >= 2 && indexPath.row < 2 + ingredients.count {
            // Ingredient input cells
            let index = indexPath.row - 2
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMealIngredientTableViewCell", for: indexPath) as! EditMealIngredientTableViewCell
            cell.ingredientTextField.text = ingredients[index]
            
            // 🗑️ Deletion handler
               cell.onDeleteTapped = { [weak self] in
                   self?.ingredients.remove(at: index)
                   self?.tableView.reloadData()
               }

            return cell
        } else if indexPath.row == ingredients.count + 2 {
            // Add row cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMealAddRowTableViewCell", for: indexPath) as! EditMealAddRowTableViewCell
            cell.onAddTapped = { [weak self] in
                guard let self = self else { return }
                self.ingredients.append("")
                self.tableView.reloadData()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditMealSaveButtonTableViewCell", for: indexPath) as! EditMealSaveButtonTableViewCell
            cell.onSaveTapped = { [weak self] in
                guard let self = self, let uid = Auth.auth().currentUser?.uid else { return }
                
                // Assuming you're editing an existing meal and you have its ID
                let updatedData: [String: Any] = [
                    "name": self.mealName,
                    "ingredients": self.ingredients,
                ]
                
                let mealRef = Firestore.firestore().collection("meals").whereField("userId", isEqualTo: uid).whereField("name", isEqualTo: self.mealName)

                mealRef.getDocuments { snapshot, error in
                    if let doc = snapshot?.documents.first {
                        Firestore.firestore().collection("meals").document(doc.documentID).updateData(updatedData) { error in
                            if let error = error {
                                print("❌ Failed to update meal:", error.localizedDescription)
                            } else {
                                print("✅ Meal updated.")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
            return cell
        }
    }
}
