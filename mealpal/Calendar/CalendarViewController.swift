//
//  CalendarViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 5/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.meals = docs.compactMap { doc in
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
                    self.tableView.reloadData()
                }
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMeals()
    }
}
