//
//  AccountLogoutTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import UIKit

class AccountLogoutTableViewCell: UITableViewCell {

    @IBOutlet weak var logoutButton: UIButton!
    var onLogoutTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        onLogoutTapped?()
    }
}
