//
//  GroceryItemCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class GroceryItemCell: UITableViewCell {

    // Closure for delete action
    var onDeleteTapped: (() -> Void)?

    @IBOutlet weak var ShoppingLabel: UILabel!
    @IBOutlet weak var GroceryItemLabel: UILabel!
    @IBOutlet weak var ShoppingHistoryButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  
    @IBAction func deleteTapped(_ sender: UIButton) {
        onDeleteTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
