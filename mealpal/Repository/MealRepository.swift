//
//  MealRepository.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MealRepository {
    static let shared = MealRepository()
    private init() {}

    private var meals: [Meal] = []

    func add(meal: Meal) {
        meals.append(meal)
        // Optionally save to Firestore as well
        saveMealToFirestore(meal: meal)
    }

    func getMeals(for date: Date) -> [Meal] {
        return meals.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func allMeals() -> [Meal] {
        return meals
    }

    // Save meal to Firestore for the current user
    func saveMealToFirestore(meal: Meal, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let mealData: [String: Any] = [
            "userId": uid,
            "title": meal.title,
            "name": meal.name,
            "imageName": meal.imageName,
            "date": Timestamp(date: meal.date),
            "ingredients": meal.ingredients
        ]

        Firestore.firestore().collection("meals").addDocument(data: mealData) { error in
            if let error = error {
                print(" Failed to save meal to Firestore:", error.localizedDescription)
            } else {
                print(" Meal saved to Firestore for user:", uid)
            }
            completion?(error)
        }
    }
}
