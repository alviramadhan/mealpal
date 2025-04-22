//
//  SearchTableViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var allMeals: [Meal] = [
        Meal(title: "Breakfast", name: "KFC", imageName: "food1", date: Date(), ingredients: ["Chicken", "Oil"]),
        Meal(title: "Lunch", name: "CFC", imageName: "food2", date: Date(), ingredients: ["Chicken", "Spices"])
    ]
    var filteredMeals: [Meal] = []
    var selectedSegment: Int = 0 // 0: My Meals, 1: Explore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + filteredMeals.count
    }
    
    
    func applyFilter() {
        if selectedSegment == 0 {
            // My Meals: Show allMeals with a specific condition (you can adjust)
            filteredMeals = allMeals.filter { $0.title == "Breakfast" || $0.title == "Lunch" }
        } else {
            // Explore: Show all meals that are not in "My Meals"
            filteredMeals = allMeals.filter { $0.title != "Breakfast" && $0.title != "Lunch" }
        }
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Search Bar
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBarTableViewCell", for: indexPath) as! SearchBarTableViewCell
            cell.SearchScSearchBar.placeholder = "Search meals..."
            cell.SearchScSearchBar.delegate = self
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
