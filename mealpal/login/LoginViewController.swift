//
//  LoginViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 23/3/2025.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginLoginbutton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        loginPasswordTextField.rightView = eyeButton
        loginPasswordTextField.rightViewMode = .always
        loginPasswordTextField.isSecureTextEntry = true
    }

    @objc func togglePasswordVisibility(_ sender: UIButton) {
        loginPasswordTextField.isSecureTextEntry.toggle()
        let imageName = loginPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        // programmatically navigate to HomeVC
        let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") as? UITabBarController
            
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
}
