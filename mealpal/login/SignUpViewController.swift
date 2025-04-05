//
//  SignUpViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 23/3/2025.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var signupUsernameTextField: UITextField!
    @IBOutlet weak var signupConfirmPasswordTextFIeld: UITextField!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var signupEmailTextField: UITextField!
    override func viewDidLoad() {
        
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let eyeButton2 = UIButton(type: .custom)
        eyeButton2.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton2.tintColor = .gray
        eyeButton2.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        eyeButton2.addTarget(self, action: #selector(togglePasswordVisibility2), for: .touchUpInside)
        
        signupPasswordTextField.rightView = eyeButton
        signupPasswordTextField.rightViewMode = .always
        signupPasswordTextField.isSecureTextEntry = true
        
        signupConfirmPasswordTextFIeld.rightView = eyeButton2
        signupConfirmPasswordTextFIeld.rightViewMode = .always
        signupConfirmPasswordTextFIeld.isSecureTextEntry = true
    }

    @objc func togglePasswordVisibility(_ sender: UIButton) {
        signupPasswordTextField.isSecureTextEntry.toggle()
        let imageName = signupPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc func togglePasswordVisibility2(_ sender: UIButton) {
        signupConfirmPasswordTextFIeld.isSecureTextEntry.toggle()
        let imageName = signupConfirmPasswordTextFIeld.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
}


 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


