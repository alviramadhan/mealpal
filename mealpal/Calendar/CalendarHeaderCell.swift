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
    @IBOutlet weak var calendarCalendarButton: UIButton!
    @IBOutlet weak var calendarScrollView: UIScrollView!
    @IBOutlet weak var calendarHeaderMonthYearLabel: UILabel!
    
    @IBAction func previousArrowTapped(_ sender: Any) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: -5, to: selectedDate) else { return }
           selectedDate = newDate
           updateDateButtons()
           onDateChanged?(newDate)
    }

    @IBAction func nextArrowTapped(_ sender: Any) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: 5, to: selectedDate) else { return }
           selectedDate = newDate
           updateDateButtons()
           onDateChanged?(newDate)
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
        updateDateButtons()
        onDateChanged?(newDate)
    }

}
