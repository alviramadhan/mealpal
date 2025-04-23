//
//  CalendarHeaderCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//

import UIKit

class CalendarHeaderCell: UITableViewCell {

    var onDateChanged: ((Date) -> Void)?
    var currentStartDate: Int = 1
    var selectedDate = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy" // Example: "March 2025"
        return formatter
    }()
    
    func updateDateButtons() {
        calendarHeaderMonthYearLabel.text = dateFormatter.string(from: selectedDate)

        for (i, button) in calendarDateButtons.enumerated() {
            guard let newDate = Calendar.current.date(byAdding: .day, value: i, to: selectedDate) else { continue }

            let day = Calendar.current.component(.day, from: newDate)
            button.setTitle("\(day)", for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            button.isHidden = false
        }
    }
    
    @IBOutlet var calendarDateButtons: [UIButton]!
    @IBOutlet weak var calendarRightArrowButton: UIButton!
    @IBOutlet weak var calendarLeftArrowButton: UIButton!
    @IBOutlet weak var calendarScrollView: UIScrollView!
    @IBOutlet weak var calendarHeaderMonthYearLabel: UILabel!
    
    @IBAction func previousArrowTapped(_ sender: Any) {
        // Subtract 1 day from the current selected date (shifting 1 day backward)
        guard let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else { return }

        selectedDate = newDate
        updateDateButtons() // Refresh buttons
        onDateChanged?(newDate) // Notify the parent controller of the updated date
    }

    @IBAction func nextArrowTapped(_ sender: Any) {
        // Add 1 day from the current selected date (shifting 1 day forward)
        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else { return }

        selectedDate = newDate
        updateDateButtons() // Refresh buttons
        onDateChanged?(newDate) // Notify the parent controller of the updated date
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateDateButtons()
    }
    
    @objc func dateButtonTapped(_ sender: UIButton) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: sender.tag, to: selectedDate) else { return }
        selectedDate = newDate
        updateDateButtons() // Ensure the date buttons are refreshed
        onDateChanged?(newDate)
    }

}
