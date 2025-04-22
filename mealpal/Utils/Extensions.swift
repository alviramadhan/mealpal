//
//  Extensions.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import Foundation
import UIKit
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true)
    }
}
