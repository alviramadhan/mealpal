//
//  CalendarViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 5/4/2025.
//

import UIKit

class CalendarViewController: UITableViewController {
    
    func getDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        return Calendar.current.date(from: components) ?? Date()
    }

    var meals = [
        Meal(title: "Breakfast", name: "Omelette", imageName: "foodsample1", date: Date(), ingredients: ["Egg", "Cheese", "Tomato"]),
        Meal(title: "Lunch", name: "Grilled Chicken", imageName: "foodsample1", date: Date(), ingredients: ["Chicken", "Spices", "Olive Oil"]),
        Meal(title: "Dinner", name: "Pasta", imageName: "foodsample1", date: Date(), ingredients: ["Pasta", "Sauce", "Parmesan"])
    ]
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
        meals = MealRepository.shared.getMeals(for: selectedDate)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMeals()
    }
}
