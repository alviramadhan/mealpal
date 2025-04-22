//
//  EditMealIngredientTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import UIKit

class EditMealIngredientTableViewCell: UITableViewCell {
 
    @IBOutlet weak var ingredientTextField: UITextField!
    
    @IBOutlet weak var ingredientDeleteButton: UIButton!
    
    var onTextChanged: ((String) -> Void)?
    var onDeleteTapped: (() -> Void)?

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDeleteTapped?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ingredientTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func textFieldChanged() {
        onTextChanged?(ingredientTextField.text ?? "")
    }

}
