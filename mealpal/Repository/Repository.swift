//
//  Repository.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class Repository {
    func loginUser(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        })
    }
    func signUpUser(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ Firebase Auth sign-up failed:", error.localizedDescription)
                completion(.failure(error))
            } else if let user = result?.user {
                print("✅ Firebase Auth successful. UID:", user.uid, "Password stored securely in Firebase Auth.")
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": email,
                    "name": name
                ]
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("❌ Failed to save user to Firestore:", error.localizedDescription)
                        completion(.failure(error))
                    } else {
                        print("✅ User saved to Firestore:", userData)
                        completion(.success(()))
                    }
                }
            }
        }
    }

}
