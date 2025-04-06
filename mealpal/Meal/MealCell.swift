//
//  MealCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class MealCell: UITableViewCell {

    
    @IBOutlet weak var homeMealTitle: UILabel!
    
    @IBOutlet weak var homeMealImageView: UIImageView!
    
    @IBOutlet weak var homeMealNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
