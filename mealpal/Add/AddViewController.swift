//
//  AddViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AddViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddInputIngredientCell", for: indexPath)
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
    
    func saveMeal() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        for i in 0..<ingredients.count {
            let indexPath = IndexPath(row: 3 + i, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? AddInputIngredientCell {
                ingredients[i] = cell.InputIngredientTextField.text ?? ""
            }
        }

        let filteredIngredients = self.ingredients.filter { !$0.isEmpty }

        // If user has selected an image, upload it. Otherwise use a default placeholder URL.
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            let imageRef = Storage.storage().reference().child("meal_images/\(UUID().uuidString).jpg")
            
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
                    self.saveMealToFirestore(uid: uid, imageUrl: imageUrl, ingredients: filteredIngredients)
                }
            }
        } else {
            // Default placeholder image URL if no image was selected
            let placeholderUrl = "https://via.placeholder.com/150"
            self.saveMealToFirestore(uid: uid, imageUrl: placeholderUrl, ingredients: filteredIngredients)
        }
    }

    private func saveMealToFirestore(uid: String, imageUrl: String, ingredients: [String]) {
        let ref = Firestore.firestore().collection("meals").document()
        let mealData: [String: Any] = [
            "userId": uid,
            "title": selectedTitle,
            "name": mealName,
            "imageName": imageUrl,
            "date": Timestamp(date: selectedDate),
            "ingredients": ingredients
        ]

        ref.setData(mealData) { error in
            if let error = error {
                print("❌ Failed to save meal to Firestore:", error.localizedDescription)
                return
            }
            print("✅ Meal saved with Firestore document ID:", ref.documentID)
            // Only add to repository after Firestore save succeeds, if needed
            // MealRepository.shared.add(meal: meal)
            print("Meal: \(self.selectedTitle) - \(self.mealName)")
        }

        let db = Firestore.firestore()
        for item in ingredients {
            let groceryData: [String: Any] = ["name": item, "userId": uid]
            db.collection("groceryItems").addDocument(data: groceryData)
        }

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
