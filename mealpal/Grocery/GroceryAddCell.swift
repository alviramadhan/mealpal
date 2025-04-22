//
//  GroceryAddCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class GroceryAddCell: UITableViewCell {

    @IBOutlet weak var GroceryInputTextfield: UITextField!
    
    // losure that the VC will set
       var onDeleteTapped: (() -> Void)?

    
    @IBOutlet weak var GroceryDeleteButton: UIButton!
    @IBAction func onDeleteTapped(_ sender: UIButton) {
        onDeleteTapped?()  //if delete tapped is nil, do nothing
    }
    
    var onTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        onTextChanged?(sender.text ?? "")
    }
}
