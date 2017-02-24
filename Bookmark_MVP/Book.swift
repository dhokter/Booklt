//
//  Book.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import Foundation
import UIKit

class Book {
    // Properties of book
    var titleBook: String
    var pageNumber: Int
    var currentPage: Int
    var bookCover: UIImage?
    var author: String
    
    //Failable initializer
    init?(titleBook: String, pageNumber: Int, bookCover: UIImage?, currentPage: Int = 0, author: String = "") {
        if titleBook.isEmpty || pageNumber < 0 || currentPage < 0 {
            return nil
        }
        self.titleBook = titleBook
        self.pageNumber = pageNumber
        self.bookCover = bookCover
        self.currentPage = currentPage
        self.author = ""
    }
}
