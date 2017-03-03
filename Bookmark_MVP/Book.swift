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
    var title: String
    var totalPages: Int
    var currentPage: Int
    var cover: UIImage?
    var author: String
    
    //Failable initializer
    init?(title: String, totalPages: Int, cover: UIImage? = #imageLiteral(resourceName: "default"), currentPage: Int = 0, author: String = "") {
        if title.isEmpty || totalPages < 0 || currentPage < 0 {
            return nil
        }
        self.title = title
        self.totalPages = totalPages
        self.cover = cover
        self.currentPage = currentPage
        self.author = author
    }
    
    
}
