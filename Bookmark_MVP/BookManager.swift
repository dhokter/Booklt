//
//  BookManagerModel.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/27/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

let bookManager = BookManager()

class BookManager {
    
    let realm = try! Realm()
    
    // List of all books in the inventory.
//    public var allBooks: [Book] {
//        get {
//            return Array(realm.objects(Book.self))
//        }
//    }
    
    // List of all books being displayed.
    public var readingBooks: [Book] {
        get {
            return Array(realm.objects(Book.self)).filter({$0.isReading})
        }
    }
    
    public var finishedBooks: [Book] {
        get {
            return Array(realm.objects(Book.self).filter({!$0.isReading}))
        }
    }

    public func addNewBook(book: Book) {
        try! realm.write {
            realm.add(book)
        }
    }
    
    public func markAsFinished(book: Book) {
        try! realm.write {
            book.isReading = false
        }
    }
    
    public func markAsReading(book: Book) {
        try! realm.write {
            book.isReading = true
        }
    }
    
    public func delete(book: Book) {
        try! realm.write {
            realm.delete(book)
        }
    }
}
