//
//  SearchBarTableViewCell.swift
//  mealpal
//
//  Created by Alvi Ramadhan on 11/4/2025.
//

import UIKit

class SearchBarTableViewCell: UITableViewCell, UISearchBarDelegate {


    @IBOutlet weak var SearchScSearchBar: UISearchBar!
    

    var onSearchChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
     //   SearchScSearchBar.delegate = self
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onSearchChanged?(searchText)
    }
}
