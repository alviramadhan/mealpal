//
//  AddSaveButtonCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class AddSaveButtonCell: UITableViewCell {
    
    var onSaveTapped: (() -> Void)?
    @IBOutlet weak var addSaveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        onSaveTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
