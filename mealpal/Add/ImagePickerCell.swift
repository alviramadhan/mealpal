//
//  ImagePickerTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 6/4/2025.
//


import UIKit

class ImagePickerCell: UITableViewCell {
    @IBOutlet weak var mealImageView: UIImageView!

    var imageTapCallback: (() -> Void)? // I will let the parent VC handle the picker

    override func awakeFromNib() {
        super.awakeFromNib()
        
        mealImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        mealImageView.addGestureRecognizer(tapGesture)
    }

    @objc func imageTapped() {
        imageTapCallback?()
    }
}

