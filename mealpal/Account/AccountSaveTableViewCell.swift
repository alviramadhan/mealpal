//
//  AccountSaveTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import UIKit

class AccountSaveTableViewCell: UITableViewCell {

    @IBOutlet weak var saveButton: UIButton!
    var onSaveTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        onSaveTapped?()
    }
}
