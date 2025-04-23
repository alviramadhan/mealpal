//
//  SearchTableViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit
import FirebaseAuth

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var allMeals: [Meal] = []
    var filteredMeals: [Meal] = []
    var selectedSegment: Int = 0 // 0: My Meals, 1: Explore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserMeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserMeals()
    }
    
    func fetchUserMeals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Fetch all meals (both assigned and template) for the logged-in user
        MealRepository.shared.fetchMeals(forUserId: uid) { meals in
            self.allMeals = meals
            self.applyFilter()  // Apply any necessary filter if needed (like search text)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + filteredMeals.count
    }

    func applyFilter(withSearchText searchText: String = "") {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Show all meals for the current user
        let baseFiltered: [Meal] = allMeals.filter { $0.userId == uid }

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
            // Load image from URL if meal.imageName is a valid URL, else fallback to local asset
            if let url = URL(string: meal.imageName), meal.imageName.hasPrefix("http") {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.SearchScImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            } else {
                // Use local asset image if no valid URL
                cell.SearchScImageView.image = UIImage(named: meal.imageName)  // Default image from assets
            }
            
            cell.onEditTapped = { [weak self] in
                guard let self = self else { return }
                let meal = self.filteredMeals[indexPath.row - 2]
                self.performSegue(withIdentifier: "EditMealSegue", sender: meal)
            }
            
            return cell
        
//            // Swipe to delete functionality
//            cell.onDeleteTapped = { [weak self] in
//                guard let self = self else { return }
//                let meal = self.filteredMeals[indexPath.row - 2]
//                self.deleteMealFromRepository(meal: meal, at: indexPath)
//            }
//            
        
        }
    }

    // Swipe to delete functionality
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let meal = filteredMeals[indexPath.row - 2]
            deleteMealFromRepository(meal: meal, at: indexPath)
        }
    }

    // Delete meal from repository and Firestore
    func deleteMealFromRepository(meal: Meal, at indexPath: IndexPath) {
        MealRepository.shared.deleteMeal(withId: meal.id) { error in
            if let error = error {
                print(" Failed to delete meal from Firestore:", error.localizedDescription)
                return
            }
            self.filteredMeals.remove(at: indexPath.row - 2)  // Adjust the index correctly
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }

    // MARK: - Navigation for Editing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditMealSegue",
           let destination = segue.destination as? EditMealTableViewController,
           let meal = sender as? Meal {
            destination.mealDocumentId = meal.id
        }
    }
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
        let meal = filteredMeals[indexPath.row - 2]
        MealRepository.shared.deleteTemplateMeal(withId: meal.id) { error in
            if error == nil {
                self.filteredMeals.remove(at: indexPath.row - 2)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
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
    

