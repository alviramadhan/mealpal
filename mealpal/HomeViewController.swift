//
//  HomeViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 5/4/2025.
//

import UIKit

class HomeViewController: UITableViewController {

    let meals = [
        Meal(title: "Breakfast", name: "Omelette", imageName: "foodsample1", date: Date(), ingredients: ["Egg", "Cheese", "Tomato"]),
        Meal(title: "Lunch", name: "Grilled Chicken", imageName: "foodsample1", date: Date(), ingredients: ["Chicken", "Spices", "Olive Oil"]),
        Meal(title: "Dinner", name: "Pasta", imageName: "foodsample1", date: Date(), ingredients: ["Pasta", "Sauce", "Parmesan"])
    ]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealCell
            let meal = meals[indexPath.row - 1]
            cell.homeMealTitle.text = meal.title
            cell.homeMealImageView.image = UIImage(named: meal.imageName)
            cell.homeMealNameLabel.text = meal.name
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
