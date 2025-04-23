import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderTableViewCell", for: indexPath) as! AccountHeaderTableViewCell

            if let uid = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
                    if let data = snapshot?.data() {
                        cell.nameLabel.text = data["name"] as? String
                        cell.emailLabel.text = data["email"] as? String
                    }
                }
            }

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountEditTableViewCell", for: indexPath) as! AccountEditTableViewCell

            if let uid = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
                    if let data = snapshot?.data() {
                        cell.nameTextField.text = data["name"] as? String
                        cell.emailTextField.text = data["email"] as? String
                    }
                }
            }

            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountSaveTableViewCell", for: indexPath) as! AccountSaveTableViewCell
            cell.onSaveTapped = { [weak self] in
                guard let self = self else { return }
                if let editCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AccountEditTableViewCell,
                   let uid = Auth.auth().currentUser?.uid,
                   let name = editCell.nameTextField.text,
                   let email = editCell.emailTextField.text,
                   let password = editCell.passwordTextField.text {

                   //checking if there are changes
                    Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
                        guard let data = snapshot?.data(),
                              let currentName = data["name"] as? String,
                              let currentEmail = data["email"] as? String else { return }

                        let changesExist = name != currentName || email != currentEmail || !password.isEmpty
                        if !changesExist {
                            self.showToast(message: "No changes to save.")
                            return
                        }

                        // Update Firestore name and email or password
                        Firestore.firestore().collection("users").document(uid).updateData([
                            "name": name,
                            "email": email
                        ]) { error in
                            if let error = error {
                                print("Failed to update user info: \(error.localizedDescription)")
                            } else {
                                self.showToast(message: "Profile updated.")
                                if !password.isEmpty, let user = Auth.auth().currentUser {
                                    Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
                                        if let data = snapshot?.data(),
                                           let storedEmail = data["email"] as? String {
                                            // Ask user to re-enter current password
                                            let alert = UIAlertController(title: "Reauthenticate", message: "Enter your current password to update the new password.", preferredStyle: .alert)
                                            alert.addTextField { textField in
                                                textField.placeholder = "Current Password"
                                                textField.isSecureTextEntry = true
                                            }
                                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                                                let currentPassword = alert.textFields?.first?.text ?? ""
                                                let credential = EmailAuthProvider.credential(withEmail: storedEmail, password: currentPassword)

                                                user.reauthenticate(with: credential) { _, error in
                                                    if let error = error {
                                                        self.showToast(message: "Reauthentication failed.")
                                                        print("❌ Reauth failed: \(error.localizedDescription)")
                                                    } else {
                                                        // Update Firebase Auth email
                                                        user.updateEmail(to: email) { error in
                                                            if let error = error {
                                                                self.showToast(message: "Auth email update failed.")
                                                                print("❌ Email update failed: \(error.localizedDescription)")
                                                            } else {
                                                                self.showToast(message: "Email updated.")
                                                            }
                                                        }

                                                        // Update Firebase Auth password if changed
                                                        if !password.isEmpty {
                                                            user.updatePassword(to: password) { error in
                                                                if let error = error {
                                                                    self.showToast(message: "Password update failed.")
                                                                    print("❌ Password update failed: \(error.localizedDescription)")
                                                                } else {
                                                                    self.showToast(message: "Password updated.")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }))
                                            self.present(alert, animated: true)
                                        }
                                    }
                                }
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                            }
                        }
                    }
                }
            }
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountLogoutTableViewCell", for: indexPath) as! AccountLogoutTableViewCell
            cell.onLogoutTapped = {
                do {
                    try Auth.auth().signOut()
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        sceneDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    }
                } catch let error {
                    print(" Logout failed: \(error.localizedDescription)")
                }
            }
            return cell

        default:
            fatalError("Unhandled row")
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
