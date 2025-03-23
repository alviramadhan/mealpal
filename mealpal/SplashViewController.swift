//
//  SplashViewController.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 23/3/2025.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var splashImageView: UIImageView!
    
    @IBOutlet weak var splashSignUpButton: UIButton!
    
    @IBOutlet weak var splashLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start hidden or off-screen
        splashImageView.alpha = 0
        splashLoginButton.alpha = 0
        splashSignUpButton.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Fade and bounce logo
        splashImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut,
                       animations: {
            self.splashImageView.alpha = 1
            self.splashImageView.transform = .identity
        })

        // Slide up buttons after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 1.0) {
                self.splashLoginButton.alpha = 1
                self.splashSignUpButton.alpha = 1
            }
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

}
