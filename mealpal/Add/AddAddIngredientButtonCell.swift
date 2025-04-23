//
//  AddAddButtonCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

//this is for adding more inouting rows

import UIKit

class AddAddIngredientButtonCell: UITableViewCell {

    
    @IBOutlet weak var AddIngredientRowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var onAddTapped: (() -> Void)?
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        onAddTapped?()
    }
    

}
