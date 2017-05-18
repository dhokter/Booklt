//
//  SearchNewBookTableViewCell.swift
//  BookIt
//
//  Created by Duc Le on 5/16/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class SearchNewBookTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    var book: BookFromAPI? {
        didSet {
            if let book = self.book {
                titleLabel.text = book.title
                authorLabel.text = book.authors.joined(separator: ", ")
                // TODO: The cover of the book is now based on color, change it to make it become an image for the purpose of using GoogleBookAPI.
                // This may need to work with NSData to store the image data into Realm.
                coverImage.image = book.cover
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
