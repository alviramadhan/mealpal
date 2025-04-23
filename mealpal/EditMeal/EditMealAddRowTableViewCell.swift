//
//  EditMealAddRowTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 22/4/2025.
//

import UIKit

class EditMealAddRowTableViewCell: UITableViewCell {

    var onAddTapped: (() -> Void)?
    @objc func onTapped(_ sender: UIButton) {
        print("🟩 Add Row button tapped in EditMealAddRowTableViewCell")
        onAddTapped?()
    }
    @IBOutlet weak var AddRowButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        AddRowButton.addTarget(self, action: #selector(onTapped(_:)), for: .touchUpInside)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
