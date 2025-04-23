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
                            id: doc.documentID, userId: uid,
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
        let picker = UIAlertController(title: "Select a \(type)", message: nil, preferredStyle: .alert)

        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    for doc in docs {
                        let data = doc.data()
                        let mealName = data["name"] as? String ?? ""
                        let imageName = data["imageName"] as? String ?? ""
                        let ingredients = data["ingredients"] as? [String] ?? []
                        let meal = Meal(
                            id: UUID().uuidString, // generate a temp ID to avoid using the original Firestore ID
                            userId: uid,
                            title: type,
                            name: mealName,
                            imageName: imageName,
                            date: Date(),
                            ingredients: ingredients
                        )
                        picker.addAction(UIAlertAction(title: meal.name, style: .default) { _ in
                            self.assignMeal(meal, to: self.selectedDate, as: type)
                        })
                    }
                    picker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(picker, animated: true)
                }
            }
    }

    func assignMeal(_ meal: Meal, to date: Date, as type: String) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let mealData: [String: Any] = [
            "userId": uid,
            "title": type,
            "name": meal.name,
            "imageName": meal.imageName,
            "date": Timestamp(date: date),
            "ingredients": meal.ingredients
        ]

        Firestore.firestore().collection("meals").addDocument(data: mealData) { error in
            if let error = error {
                print("❌ Error assigning meal:", error.localizedDescription)
            } else {
                print("✅ Meal assigned to \(type) on \(date)")
                self.reloadMeals()
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.row >= 2 else { return } // Skip non-meal rows

        if editingStyle == .delete {
            let meal = meals[indexPath.row - 2]
            Firestore.firestore().collection("meals").document(meal.id).delete { error in
                if let error = error {
                    print("❌ Failed to delete meal:", error.localizedDescription)
                } else {
                    print("🗑️ Deleted meal:", meal.name)
                    self.meals.remove(at: indexPath.row - 2)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
