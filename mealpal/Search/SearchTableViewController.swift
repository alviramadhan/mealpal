//
//  SearchTableViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var allMeals: [Meal] = []
    var filteredMeals: [Meal] = []
    var selectedSegment: Int = 0 // 0: My Meals, 1: Explore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserMeals()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let searchCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SearchBarTableViewCell {
            searchCell.SearchScSearchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserMeals()
    }
    
    func fetchUserMeals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.allMeals = docs.compactMap { doc in
                        let data = doc.data()
                        return Meal(
                            userId: uid,
                            title: data["title"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            imageName: data["imageName"] as? String ?? "",
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            ingredients: data["ingredients"] as? [String] ?? []
                        )
                    }
                    self.applyFilter()
                }
            }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + filteredMeals.count
    }
    
    
    func applyFilter(withSearchText searchText: String = "") {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let baseFiltered: [Meal]
        if selectedSegment == 0 {
            baseFiltered = allMeals.filter { $0.userId == uid }
        } else {
            baseFiltered = allMeals.filter { $0.userId != uid }
        }

        if searchText.isEmpty {
            filteredMeals = baseFiltered
        } else {
            filteredMeals = baseFiltered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        tableView.reloadData()
    }

    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(withSearchText: searchText)
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Search Bar
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBarTableViewCell", for: indexPath) as! SearchBarTableViewCell
            cell.onSearchChanged = { [weak self] text in
                self?.applyFilter(withSearchText: text)
            }
            return cell
        } else if indexPath.row == 1 {
            // Segmented Control
            let cell = tableView.dequeueReusableCell(withIdentifier: "MealSwitchTableViewCell", for: indexPath) as! MealSwitchTableViewCell
            cell.MealSwitcher.selectedSegmentIndex = selectedSegment
            cell.onSegmentChanged = { [weak self] index in
                self?.selectedSegment = index
                self?.applyFilter()
            }
            return cell
            
        } else {
            // Meal Result Cell
            let meal = filteredMeals[indexPath.row - 2]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
            cell.SearchScMealNameLabel.text = meal.name
            cell.SearchScImageView.image = UIImage(named: meal.imageName)
            
            return cell
            
            
        }
        
        
        
        /*
         // Override to support conditional editing of the table view.
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
         }
         */
        
        /*
         // Override to support editing the table view.
         override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
         // Delete the row from the data source
         tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
         }
         */
        
        /*
         // Override to support rearranging the table view.
         override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         
         }
         */
        
        /*
         // Override to support conditional rearranging of the table view.
         override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
         }
         */
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}
