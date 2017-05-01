//
//  SearchBookTableViewCell.swift
//  BookIt
//
//  Created by Duc Le on 3/24/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class SearchBookTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var book: BookFromAPI? {
        didSet {
            if let book = self.book {
                coverImage.image = book.cover
                titleLabel.text = book.title
                authorLabel.text = book.authors.joined(separator: ", ")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
