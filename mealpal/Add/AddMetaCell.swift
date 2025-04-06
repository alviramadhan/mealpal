//
//  AddMetaCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class AddMetaCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleSegment: UISegmentedControl!

    var onDateChanged: ((Date) -> Void)?
    var onTitleChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
        titleSegment.addTarget(self, action: #selector(titleDidChange), for: .valueChanged)
    }

    @objc func dateDidChange() {
        onDateChanged?(datePicker.date)
    }

    @objc func titleDidChange() {
        let selected = titleSegment.titleForSegment(at: titleSegment.selectedSegmentIndex) ?? "Breakfast"
        onTitleChanged?(selected)
    }
}
