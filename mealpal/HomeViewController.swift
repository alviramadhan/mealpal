//
//  HomeViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 5/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UITableViewController {

    @IBOutlet weak var accountButton: UIBarButtonItem?
    
    var meals: [Meal] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMealsFromFirestore()
    }
    
    func fetchMealsFromFirestore() {
        MealRepository.shared.fetchMealsForToday { meals in
            self.meals = meals
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
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
            // Load image from URL if meal.imageName is a valid URL, else fallback to local asset
            if let url = URL(string: meal.imageName), meal.imageName.hasPrefix("http") {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.homeMealImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            } else {
                cell.homeMealImageView.image = UIImage(named: meal.imageName)
            }
            cell.homeMealNameLabel.text = meal.name
            return cell
        }
    }
    
    @IBAction func accountButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAccount", sender: self)
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
