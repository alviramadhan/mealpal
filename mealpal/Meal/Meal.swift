//
//  Meal.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import Foundation
struct Meal {
    let userId: String       // New: to link meal to a specific user
    let title: String        // e.g. "Breakfast"
    let name: String         // e.g. "Omelette"
    let imageName: String    // image filename or Firebase URL later
    let date: Date           // e.g. 2025-04-10
    let ingredients: [String]
}
