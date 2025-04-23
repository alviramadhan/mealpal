//
//  Repository.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserRepository {
    static let shared = UserRepository()
    private init() {}

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
                print("  Firebase Auth sign-up failed:", error.localizedDescription)
                completion(.failure(error))
            } else if let user = result?.user {
                print("Firebase Auth successful. UID:", user.uid, "Password stored securely in Firebase Auth.")
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": email,
                    "name": name
                ]
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("  Failed to save user to Firestore:", error.localizedDescription)
                        completion(.failure(error))
                    } else {
                        print(" User saved to Firestore:", userData)
                        completion(.success(()))
                    }
                }
            }
        }
    }

    func fetchUserData(completion: @escaping (_ name: String?, _ email: String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, nil)
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            let data = snapshot?.data()
            let name = data?["name"] as? String
            let email = data?["email"] as? String
            completion(name, email)
        }
    }

    func updateUserData(name: String, email: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        Firestore.firestore().collection("users").document(uid).updateData([
            "name": name,
            "email": email
        ], completion: completion)
    }

    func updateUserCredentials(email: String, password: String, currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let storedEmail = data["email"] as? String else {
                completion(error ?? NSError(domain: "DataError", code: 500, userInfo: nil))
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: storedEmail, password: currentPassword)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(error)
                } else {
                    let group = DispatchGroup()
                    var updateError: Error?

                    group.enter()
                    user.updateEmail(to: email) { error in
                        updateError = error
                        group.leave()
                    }

                    if !password.isEmpty {
                        group.enter()
                        user.updatePassword(to: password) { error in
                            updateError = error
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        completion(updateError)
                    }
                }
            }
        }
    }
}
