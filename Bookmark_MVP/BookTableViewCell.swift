//
//  BookTableViewCell.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleBookView: UILabel!
    @IBOutlet weak var progressLabelView: UILabel!
    @IBOutlet weak var currentPageView: UITextField!
    @IBOutlet weak var progressBarView: UIProgressView!
    
    // The instance of the book the cell is displaying
    var bookDisplay: Book? {
        // As this book is set, then the following display will set up
        didSet {
            if let book = bookDisplay {
                titleBookView.text = book.titleBook
                coverImageView.image = book.bookCover
                currentPageView.text = String(book.currentPage)
                progressBarView.progress = Float(book.currentPage) / Float(book.pageNumber)
                progressLabelView.text = String(Int(Float(book.currentPage)*100 / Float(book.pageNumber)))+"%"
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
