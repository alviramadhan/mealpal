//
//  GroceryAddRowTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 21/4/2025.
//

import UIKit

class GroceryAddRowTableViewCell: UITableViewCell {

    var onAddTapped: (() -> Void)?

    
    @IBOutlet weak var GroceryAddRowButton: UIButton!
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        onAddTapped?()
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
