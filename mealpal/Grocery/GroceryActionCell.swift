//
//  GroceryActionCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class GroceryActionCell: UITableViewCell {

    @IBOutlet weak var GroceryCancelButton: UIButton!
    @IBOutlet weak var grocerySaveButton: UIButton!

    var onSaveTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?

    @IBAction func saveTapped(_ sender: UIButton) {
        onSaveTapped?()
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        onCancelTapped?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
