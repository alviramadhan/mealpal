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
    
    func fetchMealsForToday(completion: @escaping ([Meal]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfToday))
            .whereField("date", isLessThan: Timestamp(date: endOfToday))
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    let meals = docs.compactMap { doc -> Meal? in
                        let data = doc.data()
                        return Meal(
                            id: doc.documentID,
                            userId: uid,
                            title: data["title"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            imageName: data["imageName"] as? String ?? "",
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            ingredients: data["ingredients"] as? [String] ?? []
                        )
                    }
                    completion(meals)
                } else {
                    completion([])
                }
            }
    }

    func fetchMeals(for date: Date, completion: @escaping ([Meal]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                let meals: [Meal] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    return Meal(
                        id: doc.documentID,
                        userId: uid,
                        title: data["title"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        imageName: data["imageName"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        ingredients: data["ingredients"] as? [String] ?? []
                    )
                } ?? []
                completion(meals)
            }
    }

    func assignMeal(_ meal: Meal, for date: Date, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let mealData: [String: Any] = [
            "userId": uid,
            "title": meal.title,
            "name": meal.name,
            "imageName": meal.imageName,
            "date": Timestamp(date: date),
            "ingredients": meal.ingredients
        ]

        Firestore.firestore().collection("meals").addDocument(data: mealData) { error in
            if let error = error {
                print("❌ Error assigning meal:", error.localizedDescription)
            } else {
                print("✅ Meal assigned to \(meal.title) on \(date)")
            }
            completion?(error)
        }
    }

    func fetchTemplateMeals(forUserId uid: String, completion: @escaping ([Meal]) -> Void) {
        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                let meals: [Meal] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    return Meal(
                        id: doc.documentID,
                        userId: uid,
                        title: data["title"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        imageName: data["imageName"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        ingredients: data["ingredients"] as? [String] ?? []
                    )
                } ?? []
                completion(meals)
            }
    }

    func deleteMeal(withId id: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("meals").document(id).delete(completion: completion)
    }

    func saveMealFromAddScreen(meal: Meal, imageUrl: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let db = Firestore.firestore()

        let templateData: [String: Any] = [
            "userId": uid,
            "title": meal.title,
            "name": meal.name,
            "imageName": imageUrl,
            "ingredients": meal.ingredients,
            "isTemplate": true
        ]
        db.collection("meals").addDocument(data: templateData)

        let assignedData: [String: Any] = [
            "userId": uid,
            "title": meal.title,
            "name": meal.name,
            "imageName": imageUrl,
            "ingredients": meal.ingredients,
            "date": Timestamp(date: meal.date),
            "isTemplate": false
        ]
        db.collection("meals").addDocument(data: assignedData) { error in
            completion?(error)
        }
    }
    
    func fetchMeal(withId id: String, completion: @escaping (Meal?) -> Void) {
        Firestore.firestore().collection("meals").document(id).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                print("❌ Firestore fetch error:", error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            let meal = Meal(
                id: id,
                userId: data["userId"] as? String ?? "",
                title: data["title"] as? String ?? "",
                name: data["name"] as? String ?? "",
                imageName: data["imageName"] as? String ?? "",
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                ingredients: data["ingredients"] as? [String] ?? []
            )
            completion(meal)
        }
    }

    func updateMeal(id: String, with data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("meals").document(id).updateData(data, completion: completion)
    }
    
    func fetchUserMeals(completion: @escaping ([Meal]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    let meals: [Meal] = docs.compactMap { doc in
                        let data = doc.data()
                        return Meal(
                            id: doc.documentID,
                            userId: uid,
                            title: data["title"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            imageName: data["imageName"] as? String ?? "",
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            ingredients: data["ingredients"] as? [String] ?? []
                        )
                    }
                    completion(meals)
                } else {
                    completion([])
                }
            }
    }
}
