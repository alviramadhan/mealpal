//
//  ResultTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var SearchScImageView: UIImageView!
    @IBOutlet weak var SearchScMealNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
