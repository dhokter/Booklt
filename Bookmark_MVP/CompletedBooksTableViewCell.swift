//
//  AllBooksTableViewCell.swift
//  BookIt
//
//  Created by Duc Le on 3/7/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class CompletedBooksTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var titleLabel:      UILabel!
    @IBOutlet weak var authorLabel:     UILabel!
    @IBOutlet weak var coverImageView:  UIImageView!
    @IBOutlet var ratingButtons:        [UIButton]!
    
    var book: Book? {
        didSet {
            // When the value of the book is set, the cell will fill out the UI with provided information
            if let book = self.book {
                titleLabel.text  = book.title
                authorLabel.text = book.author
                coverImageView.image = iconColor[book.color]
                fillStars()
            }
        }
    }
    
    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Configure the view for the selected state
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Filling the rating view according to the rating of the displayed book
    private func fillStars() {
        let rating = self.book?.rating
        if rating != 0 {
            for i in 0...rating!-1 {
                ratingButtons[i].setImage(#imageLiteral(resourceName: "star_closed"), for: UIControlState.normal)
            }
            if rating! < 5 {
                for i in rating!...4 {
                    ratingButtons[i].setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
                }
            }
        } else {
            for star in ratingButtons {
                star.setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
            }
        }
    }
    
    
}
