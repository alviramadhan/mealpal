//
//  GroceryAddCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class GroceryAddCell: UITableViewCell {

    @IBOutlet weak var GroceryInputTextfield: UITextField!
    
    @IBOutlet weak var GroceryDeleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
