//
//  ResultTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var EditMeal: UIButton!
    @IBOutlet weak var SearchScImageView: UIImageView!
    @IBOutlet weak var SearchScMealNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var onEditTapped: (() -> Void)?
    @IBAction func editButtonPressed(_ sender: UIButton) {
        onEditTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
