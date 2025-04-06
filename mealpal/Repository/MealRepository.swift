//
//  MealRepository.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import Foundation

class MealRepository {
    static let shared = MealRepository()
    private init() {}

    private var meals: [Meal] = []

    func add(meal: Meal) {
        meals.append(meal)
    }

    func getMeals(for date: Date) -> [Meal] {
        return meals.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    func allMeals() -> [Meal] {
        return meals
    }
}
