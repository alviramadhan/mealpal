//
//  AddViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class AddViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var ingredients: [String] = [""]
    var selectedImage: UIImage?
    var mealName: String = ""
    var selectedDate: Date = Date()
    var selectedTitle: String = "Breakfast"
    
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
            return tableView.dequeueReusableCell(withIdentifier: "AddMealNameCell", for: indexPath)
        } else if indexPath.row >= 3 && indexPath.row < 3 + ingredients.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddInputIngredientCell", for: indexPath)
            return cell
        } else if indexPath.row == 3 + ingredients.count {
            return tableView.dequeueReusableCell(withIdentifier: "AddAddIngredientButtonCell", for: indexPath)
        } else if indexPath.row == 4 + ingredients.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddMetaCell", for: indexPath) as! AddMetaCell
            cell.datePicker.date = selectedDate
            let titles = ["Breakfast", "Lunch", "Dinner"]
            cell.titleSegment.selectedSegmentIndex = titles.firstIndex(of: selectedTitle) ?? 0
            cell.onDateChanged = { self.selectedDate = $0 }
            cell.onTitleChanged = { self.selectedTitle = $0 }
            return cell
        } else if indexPath.row == 5 + ingredients.count {
            return tableView.dequeueReusableCell(withIdentifier: "AddSaveButtonCell", for: indexPath)
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
    
    @objc func addIngredientTapped() {
        ingredients.append("")
        let newIndexPath = IndexPath(row: 3 + ingredients.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
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
