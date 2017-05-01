//
//  WishListBooksTableViewCell.swift
//  BookIt
//
//  Created by Spencer Grant on 4/4/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class WishListBooksTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var book: Book? {
        didSet {
            if let book = self.book {
                titleLabel.text  = book.title
                authorLabel.text = book.author
                coverImage.image = iconColor[book.color]
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
}
