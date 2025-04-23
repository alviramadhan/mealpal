//
//  GroceryRepository.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class GroceryRepository {
    static let shared = GroceryRepository()
    private init() {}
    
    func fetchItems(completion: @escaping ([GroceryItem]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        Firestore.firestore().collection("groceryItems")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                let items = snapshot?.documents.compactMap { doc -> GroceryItem? in
                    let data = doc.data()
                    return GroceryItem(id: doc.documentID, name: data["name"] as? String ?? "")
                } ?? []
                completion(items)
            }
    }
    
    func deleteItem(withId id: String, completion: ((Error?) -> Void)? = nil) {
        Firestore.firestore().collection("groceryItems").document(id).delete(completion: completion)
    }
    
    //    func addItems(_ items: [String], forUser uid: String) {
    //        let db = Firestore.firestore()
    //        for item in items {
    //            let groceryData: [String: Any] = ["name": item, "userId": uid]
    //            db.collection("groceryItems").addDocument(data: groceryData)
    //        }
    //    }
    
    func addItems(_ items: [String], forUser uid: String) {
        let db = Firestore.firestore()
        for item in items {
            print("Adding item: \(item)")  // Debugging print
            let groceryData: [String: Any] = ["name": item, "userId": uid]
            db.collection("groceryItems").addDocument(data: groceryData) { error in
                if let error = error {
                    print("❌ Failed to add grocery item:", error.localizedDescription)
                } else {
                    print("✅ Successfully added grocery item: \(item)")
                }
            }
        }
    }
}
