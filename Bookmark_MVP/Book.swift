//
//  Book.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

// TODO: Not necessary to use enum. Use string to be more descriptive
enum State: Int {
    case reading = 0
    case completed = 1
    case wishList = 2
}


class Book: Object {
    
    // Properties of book
    dynamic var title: String         = ""
    dynamic var totalPages: Int       = 0
    dynamic var currentPage: Int      = 0
    dynamic var author: String        = ""
    dynamic var whenCreated: Date     = Date()
    dynamic var status: Int           = 0
    dynamic var personalNotes: String = ""
    dynamic var rating: Int           = 0
    
    
    // Failable initializer
    convenience init?(title: String, totalPages: Int, cover: UIImage? = #imageLiteral(resourceName: "default"), currentPage: Int = 0, author: String = "", status: Int = 0, whenCreated: Date = Date(), personalNotes: String = "Personal Notes", rating: Int = 0) {
        if title.isEmpty || totalPages < 0 || currentPage < 0 {
            return nil
        }
        
        self.init()
        
        self.title         = title
        self.totalPages    = totalPages
        self.currentPage   = currentPage
        self.author        = author
        self.status        = status
        self.whenCreated   = whenCreated
        self.personalNotes = personalNotes
        self.rating        = rating
    }
    
    
}
