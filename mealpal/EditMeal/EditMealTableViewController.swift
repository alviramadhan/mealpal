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
    var mealDocumentId: String = ""

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🧭 Editing meal with ID:", mealDocumentId)
        
        guard !mealDocumentId.isEmpty else {
            print("❌ mealDocumentId is empty. Cannot fetch Firestore document.")
            return
        }
        
        guard (Auth.auth().currentUser?.uid) != nil else { return }

        Firestore.firestore().collection("meals").document(mealDocumentId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("❌ Firestore fetch error:", error.localizedDescription)
                }

                if let data = snapshot?.data() {
                    print("✅ Firestore data fetched:", data)
                    self.mealName = data["name"] as? String ?? ""
                    self.ingredients = data["ingredients"] as? [String] ?? []
                    print("🧪 Parsed meal name:", self.mealName)
                    print("🧪 Parsed ingredients:", self.ingredients)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("⚠️ No data found for mealDocumentId:", self.mealDocumentId)
                }
            }
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
            if index < self.ingredients.count {
                cell.ingredientTextField.text = self.ingredients[index]
            }
            cell.onTextChanged = { [weak self] text in
                self?.ingredients[index] = text
            }
            
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

                // Update mealName from the name text field
                if let nameCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditMealNameTableViewCell {
                    self.mealName = nameCell.mealNameTextField.text ?? ""
                }

                for i in 0..<self.ingredients.count {
                    let indexPath = IndexPath(row: 2 + i, section: 0)
                    if let cell = self.tableView.cellForRow(at: indexPath) as? EditMealIngredientTableViewCell {
                        self.ingredients[i] = cell.ingredientTextField.text ?? ""
                    }
                }

                // Assuming you're editing an existing meal and you have its ID
                let updatedData: [String: Any] = [
                    "name": self.mealName,
                    "ingredients": self.ingredients,
                ]

                Firestore.firestore().collection("meals").document(self.mealDocumentId).updateData(updatedData) { error in
                    if let error = error {
                        print("❌ Failed to update meal:", error.localizedDescription)
                    } else {
                        print("✅ Meal updated.")

                        let alert = UIAlertController(title: "Update Grocery List?",
                                                      message: "Do you also want to update your grocery list with these ingredients?",
                                                      preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                            for item in self.ingredients {
                                let groceryData: [String: Any] = ["name": item, "userId": uid]
                                Firestore.firestore().collection("groceryItems").addDocument(data: groceryData)
                            }
                            self.showToast(message: "Grocery list updated ✅")
                            self.navigationController?.popViewController(animated: true)
                        }))

                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
                            self.navigationController?.popViewController(animated: true)
                        }))

                        self.present(alert, animated: true)
                    }
                }
            }
            return cell
        }
    }
}
