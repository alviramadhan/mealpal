//
//  GroceryRepository.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import Foundation
class GroceryRepository {
    static let shared = GroceryRepository()
    private init() {}

    var items: [GroceryItem] = []

    func add(_ item: GroceryItem) {
        items.append(item)
    }

    func remove(at index: Int) {
        items.remove(at: index)
    }

    func clear() {
        items.removeAll()
    }
}
