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
                            ingredients: data["ingredients"] as? [String] ?? [],
                            template: false
                            
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
                        ingredients: data["ingredients"] as? [String] ?? [],
                        template: false
                        
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
            "ingredients": meal.ingredients,
            "isTemplate": meal.template // Assigned meal
        ]

        Firestore.firestore().collection("meals").addDocument(data: mealData) { error in
            if let error = error {
                print("  Error assigning meal:", error.localizedDescription)
            } else {
                print("Meal assigned to \(meal.title) on \(date)")
            }
            completion?(error)
        }
    }

    func fetchTemplateMeals(forUserId uid: String, completion: @escaping ([Meal]) -> Void) {
        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .whereField("isTemplate", isEqualTo: false)
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
                        ingredients: data["ingredients"] as? [String] ?? [],
                        template: false
                    )
                } ?? []
                completion(meals)
            }
    }

    // Fetch assigned meals (not templates) for a user filtered by date
    func fetchAssignedMeals(forUserId uid: String, onDate date: Date, completion: @escaping ([Meal]) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)  // Fetch meals for the specific date range
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
                        ingredients: data["ingredients"] as? [String] ?? [],
                        template: data["isTemplate"] as? Bool ?? false
                    )
                } ?? []
                completion(meals)
            }
    }

    func deleteMeal(withId id: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("meals").document(id).delete(completion: completion)
    }
    
    func deleteAssignedMeal(withId id: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("meals").document(id).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let isTemplate = data["isTemplate"] as? Bool else {
                completion?(NSError(domain: "MealNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Meal not found"]))
                return
            }
            
            if isTemplate == false {
                // Proceed with deleting the assigned meal (template: false)
                Firestore.firestore().collection("meals").document(id).delete(completion: completion)
            } else {
                completion?(NSError(domain: "TemplateMealError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Cannot delete template meal"]))
            }
        }
    }

    func deleteTemplateMeal(withId id: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("meals").document(id).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let isTemplate = data["isTemplate"] as? Bool else {
                completion?(NSError(domain: "MealNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Meal not found"]))
                return
            }
            
            if isTemplate == true {
                // Proceed with deleting the template meal (template: true)
                Firestore.firestore().collection("meals").document(id).delete(completion: completion)
            } else {
                completion?(NSError(domain: "AssignedMealError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Cannot delete assigned meal"]))
            }
        }
    }

    // Save a template meal (template: true)
    func saveTemplateMeal(meal: Meal, imageUrl: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        let templateData: [String: Any] = [
            "userId": uid,
            "title": meal.title,
            "name": meal.name,
            "imageName": imageUrl,
            "ingredients": meal.ingredients,
            "isTemplate": meal.template
        ]
        Firestore.firestore().collection("meals").addDocument(data: templateData) { error in
            completion?(error)
        }
    }

    // Save an assigned meal (template: false)
    func saveAssignedMeal(meal: Meal, imageUrl: String, completion: ((Error?) -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        let assignedData: [String: Any] = [
            "userId": uid,
            "title": meal.title,
            "name": meal.name,
            "imageName": imageUrl,
            "ingredients": meal.ingredients,
            "date": Timestamp(date: meal.date),
            "isTemplate": meal.template
        ]
        Firestore.firestore().collection("meals").addDocument(data: assignedData) { error in
            completion?(error)
        }
    }

    // (Removed saveMealFromAddScreen; now handled in AddViewController)
    
    func fetchMeal(withId id: String, completion: @escaping (Meal?) -> Void) {
        Firestore.firestore().collection("meals").document(id).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                print("  Firestore fetch error:", error?.localizedDescription ?? "No data")
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
                ingredients: data["ingredients"] as? [String] ?? [],
                template: data["isTemplate"] as? Bool ?? false
            )
            completion(meal)
        }
    }

    func updateMeal(id: String, with data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("meals").document(id).updateData(data, completion: completion)
    }
    
    // Updated method to fetch all meals for a specific user (both assigned and template)
    func fetchMeals(forUserId uid: String, completion: @escaping ([Meal]) -> Void) {
        Firestore.firestore().collection("meals")
            .whereField("userId", isEqualTo: uid)  // Fetch all meals for this user
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
                        ingredients: data["ingredients"] as? [String] ?? [],
                        template: data["isTemplate"] as? Bool ?? false  // Add this field to mark the meal as a template or not
                    )
                } ?? []
                completion(meals)
            }
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
                            ingredients: data["ingredients"] as? [String] ?? [],
                            template: data["isTemplate"] as? Bool ?? false //
                        )
                    }
                    completion(meals)
                } else {
                    completion([])
                }
            }
    }
}
