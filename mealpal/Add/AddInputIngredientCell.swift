//
//  AddInputIngridientTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class AddInputIngredientCell: UITableViewCell {
    
    @IBOutlet weak var InputIngredientTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!  // Added delete button IBOutlet
    
    var onDeleteTapped: (() -> Void)?  // Closure to handle delete action
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDeleteTapped?()  // Execute the delete action when button is tapped
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
