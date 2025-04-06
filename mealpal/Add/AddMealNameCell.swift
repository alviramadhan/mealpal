//
//  AddMealNameTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class AddMealNameCell: UITableViewCell {

    @IBOutlet weak var addMealNameInput: UITextField!
    var onNameChanged: ((String) -> Void)?

      override func awakeFromNib() {
          super.awakeFromNib()
          addMealNameInput.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
      }

      @objc func nameChanged() {
          onNameChanged?(addMealNameInput.text ?? "")
      }

}
