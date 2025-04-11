//
//  SwitchTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit

class MealSwitchTableViewCell: UITableViewCell {

    var onSegmentChanged: ((Int) -> Void)?
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        onSegmentChanged?(sender.selectedSegmentIndex)
    }
    
    @IBOutlet weak var MealSwitcher: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
