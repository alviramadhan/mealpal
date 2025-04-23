//
//  CalendarViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 5/4/2025.
//

import UIKit
import FirebaseAuth

class CalendarViewController: UITableViewController {
    
    var meals: [Meal] = []
    
    func getDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        return Calendar.current.date(from: components) ?? Date()
    }

  
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM dd yyyy"
        return formatter
    }()

    var selectedDate: Date = Date() // or set from scroll
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 1 {
            // Calendar Title Cell (e.g. Meals for March 5, 2025)
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTitleCell", for: indexPath) as! CalendarTitleCell
            let formattedDate = dateFormatter.string(from: selectedDate)
            cell.calendarTitleLabel.text = "Meals for \(formattedDate)"
            return cell
        } else if indexPath.row >= 2 {
            // Meal Cards (reuse HomeView’s mealCell)
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealCell
            let meal = meals[indexPath.row - 2] // Offset by 2 (header + title)
            cell.homeMealTitle.text = meal.title
            cell.homeMealNameLabel.text = meal.name
            cell.homeMealImageView.image = UIImage(named: meal.imageName)
            return cell
        } else {
            // Calendar Header Cell (top scrollable date selector)
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarHeaderCell", for: indexPath) as! CalendarHeaderCell
            cell.selectedDate = selectedDate
            cell.onDateChanged = { [weak self] newDate in
                self?.selectedDate = newDate
                self?.reloadMeals()
            }
            return cell
        }
    }
    
    func reloadMeals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        MealRepository.shared.fetchAssignedMeals(forUserId: uid) { meals in
            self.meals = meals
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMeals()  // Fetch assigned meals
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMeals()  // Fetch assigned meals on view appear
    }
    
    @IBAction func addMealBarButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Meal", message: "Select a meal type", preferredStyle: .actionSheet)

        ["Breakfast", "Lunch", "Dinner"].forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default) { _ in
                self.presentMealSelection(for: type)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func presentMealSelection(for type: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        MealRepository.shared.fetchTemplateMeals(forUserId: uid) { meals in
            let picker = UIAlertController(title: "Select a \(type)", message: nil, preferredStyle: .alert)

            for meal in meals {
                picker.addAction(UIAlertAction(title: meal.name, style: .default) { _ in
                    let copiedMeal = Meal(
                        id: UUID().uuidString,
                        userId: meal.userId,
                        title: type,
                        name: meal.name,
                        imageName: meal.imageName,
                        date: self.selectedDate,
                        ingredients: meal.ingredients,
                        template: true // Set template to true for template meals
                    )
                    self.assignMeal(copiedMeal, to: self.selectedDate, as: type)
                })
            }
            
            picker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(picker, animated: true)
        }
    }

    func assignMeal(_ meal: Meal, to date: Date, as type: String) {
        MealRepository.shared.assignMeal(meal, for: date) { error in
            if error == nil {
                self.reloadMeals()
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.row >= 2 else { return } // Skip non-meal rows

        if editingStyle == .delete {
            let meal = meals[indexPath.row - 2]
            MealRepository.shared.deleteAssignedMeal(withId: meal.id) { error in
                if error == nil {
                    self.meals.remove(at: indexPath.row - 2)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
