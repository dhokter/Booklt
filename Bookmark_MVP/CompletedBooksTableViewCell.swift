//
//  AllBooksTableViewCell.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/7/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class CompletedBooksTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    var book: Book? {
        didSet {
            if let book = self.book {
                titleLabel.text = book.title
                authorLabel.text = book.author
                //coverImageView.image = book.cover
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
