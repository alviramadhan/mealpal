//
//  AddViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit
import FirebaseAuth

import FirebaseStorage //image upload

class AddViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func clearForm() {
        ingredients = [""]
        mealName = ""
        selectedImage = nil
        selectedDate = Date()
        selectedTitle = "Breakfast"
        tableView.reloadData()
    }
    
    func deleteIngredient(at indexPath: IndexPath) {
        // Remove the ingredient from the list
        ingredients.remove(at: indexPath.row - 3)  // Adjust index if needed
        
        // Delete the row from the table view
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }

var ingredients: [String] = [""]
var selectedImage: UIImage?
var mealName: String = ""
var selectedDate: Date = Date()
var selectedTitle: String = "Breakfast"
var onSave: ((Meal) -> Void)?

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
        return tableView.dequeueReusableCell(withIdentifier: "AddScreenTitleCell", for: indexPath)
    } else if indexPath.row == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddImagePickerCell", for: indexPath) as! ImagePickerCell
        cell.mealImageView?.image = selectedImage ?? UIImage(systemName: "photo")
        cell.imageTapCallback = {
            self.presentImagePicker()
        }
        return cell
    } else if indexPath.row == 2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMealNameCell", for: indexPath) as! AddMealNameCell
           cell.onNameChanged = { [weak self] name in
               self?.mealName = name
           }
           return cell
    } else if indexPath.row >= 3 && indexPath.row < 3 + ingredients.count {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddInputIngredientCell", for: indexPath) as! AddInputIngredientCell
           
           // Configure the cell with ingredient data
           let ingredient = ingredients[indexPath.row - 3]  // Adjust index if needed
           cell.InputIngredientTextField.text = ingredient

           // Pass the delete closure to the cell
           cell.onDeleteTapped = { [weak self] in
               guard let self = self else { return }
               self.deleteIngredient(at: indexPath)  // Call the delete method when the button is tapped
           }
        return cell
    } else if indexPath.row == 3 + ingredients.count {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddAddIngredientButtonCell", for: indexPath) as! AddAddIngredientButtonCell
        cell.onAddTapped = { [weak self] in
            self?.addIngredientTapped()
        }
        
        return cell
    } else if indexPath.row == 4 + ingredients.count {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMetaCell", for: indexPath) as! AddMetaCell
        cell.datePicker.date = selectedDate
        let titles = ["Breakfast", "Lunch", "Dinner"]
        cell.titleSegment.selectedSegmentIndex = titles.firstIndex(of: selectedTitle) ?? 0
        cell.onDateChanged = { self.selectedDate = $0 }
        cell.onTitleChanged = { self.selectedTitle = $0 }
        return cell
    } else if indexPath.row == 4 + ingredients.count + 1 { // adjusted for meta cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSaveButtonCell", for: indexPath) as! AddSaveButtonCell
        cell.onSaveTapped = { [weak self] in
            self?.saveMeal()
            self?.clearForm()
        }
        return cell
    }

    return UITableViewCell()
}

override func viewDidLoad() {
    super.viewDidLoad()
    
}
// MARK: - Table view data source

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 6 + ingredients.count // 3 fixed + n ingredients + 1 add + 1 meta + 1 save
}

func presentImagePicker() {
    let picker = UIImagePickerController()
    picker.sourceType = .photoLibrary
    picker.delegate = self
    present(picker, animated: true, completion: nil)
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)

    if let image = info[.originalImage] as? UIImage {
        self.selectedImage = image
        let imageIndexPath = IndexPath(row: 1, section: 0)
        self.tableView.reloadRows(at: [imageIndexPath], with: .automatic)
    }
}

    // MARK: - Save Meal Logic
    private var lastSavedMealId: String?

    func saveMeal() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Collect the ingredients
        for i in 0..<ingredients.count {
            let indexPath = IndexPath(row: 3 + i, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? AddInputIngredientCell {
                ingredients[i] = cell.InputIngredientTextField.text ?? ""
            }
        }

        let filteredIngredients = self.ingredients.filter { !$0.isEmpty }
        let mealId = UUID().uuidString
        self.lastSavedMealId = mealId

        // If user has selected an image, upload it. Otherwise use a default placeholder URL.
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {

            let imageRef = Storage.storage().reference().child("meal_images/\(mealId).jpg")

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("❌ Image upload failed:", error.localizedDescription)
                    return
                }

                imageRef.downloadURL { url, error in
                    guard let imageUrl = url?.absoluteString else {
                        print("❌ Failed to get image URL")
                        return
                    }

                    // Save the assigned meal (template = false)
                    MealRepository.shared.saveAssignedMeal(meal: Meal(
                        id: mealId,
                        userId: uid,
                        title: self.selectedTitle,
                        name: self.mealName,
                        imageName: imageUrl,
                        date: self.selectedDate,
                        ingredients: filteredIngredients,
                        template: false // Assigned meal
                    ), imageUrl: imageUrl) { error in
                        if let error = error {
                            print("❌ Error saving assigned meal:", error.localizedDescription)
                        } else {
                            // Add ingredients to groceryItems collection after meal is saved
                            self.addIngredientsToGrocery(ingredients: filteredIngredients)
                            self.showTemplateConversionAlert()  // After saving, ask user if they want to create a template
                        }
                    }
                }
            }
        } else {
            // Default placeholder image URL if no image was selected
            let placeholderUrl = "https://via.placeholder.com/150"
            MealRepository.shared.saveAssignedMeal(meal: Meal(
                id: mealId,
                userId: uid,
                title: selectedTitle,
                name: mealName,
                imageName: placeholderUrl,
                date: selectedDate,
                ingredients: filteredIngredients,
                template: false // Assigned meal
            ), imageUrl: placeholderUrl) { error in
                if let error = error {
                    print("❌ Error saving assigned meal:", error.localizedDescription)
                } else {
                    // Add ingredients to groceryItems collection after meal is saved
                    self.addIngredientsToGrocery(ingredients: filteredIngredients)
                    self.showTemplateConversionAlert()  // After saving, ask user if they want to create a template
                }
            }
        }
    }

    // Add ingredients to groceryItems collection
    func addIngredientsToGrocery(ingredients: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        GroceryRepository.shared.addItems(ingredients, forUser: uid)
    }

    // MARK: - Template Conversion Alert
    func showTemplateConversionAlert() {
        let alert = UIAlertController(title: "Save as Template?", message: "Do you want to save this meal as a template for future use?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.createTemplateMeal()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Create Template Meal
    func createTemplateMeal() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Fetch the last saved assigned meal (template: false)
        guard let mealId = self.lastSavedMealId else { return }
        
        MealRepository.shared.fetchMeal(withId: mealId) { meal in
            guard let meal = meal else { return }
            
            // Create a new meal with the same details but set template = true
            let templateMeal = Meal(
                id: UUID().uuidString,  // New meal ID
                userId: uid,
                title: meal.title,
                name: meal.name,
                imageName: meal.imageName,
                date: meal.date,
                ingredients: meal.ingredients,
                template: true  // Template meal
            )

            // Save the new template meal
            MealRepository.shared.saveTemplateMeal(meal: templateMeal, imageUrl: meal.imageName) { error in
                if let error = error {
                    print("❌ Error saving template meal:", error.localizedDescription)
                } else {
                    print("✅ Template meal saved successfully!")
                }
            }
        }
    }

    private func saveMealToFirestore(uid: String, imageUrl: String, ingredients: [String]) {
        let meal = Meal(
            id: UUID().uuidString,
            userId: uid,
            title: selectedTitle,
            name: mealName,
            imageName: imageUrl,
            date: selectedDate,
            ingredients: ingredients, template: false
        )
        
        
        
        MealRepository.shared.saveAssignedMeal(meal: meal, imageUrl: imageUrl) { error in
            if let error = error {
                print("❌ Failed to save assigned meal to Firestore:", error.localizedDescription)
                return
            }
            
            // Show the template conversion alert
            self.showTemplateConversionAlert()
            
            GroceryRepository.shared.addItems(ingredients, forUser: uid)
            
            let alert = UIAlertController(title: "Success", message: "Meal saved!", preferredStyle: .alert)
            self.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                alert.dismiss(animated: true) {
                    if let tabBarController = self.tabBarController,
                       let viewControllers = tabBarController.viewControllers,
                       viewControllers.count > 1,
                       let nav = viewControllers[1] as? UINavigationController,
                       let calendarVC = nav.viewControllers.first as? CalendarViewController {
                        calendarVC.reloadMeals()
                    }
                    self.clearForm()
                }
            }
        }
    }

@objc func addIngredientTapped() {
    ingredients.append("")
    let newIndexPath = IndexPath(row: 3 + ingredients.count - 1, section: 0)
    tableView.insertRows(at: [newIndexPath], with: .automatic)
}


override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row >= 3 && indexPath.row < 3 + ingredients.count
}

override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete && indexPath.row >= 3 && indexPath.row < 3 + ingredients.count {
        ingredients.remove(at: indexPath.row - 3)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/

}
