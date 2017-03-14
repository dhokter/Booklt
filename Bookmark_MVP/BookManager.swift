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

    // List of all the books that the user is currently reading.
    public var readingBooks: [Book] {
        return Array(realm.objects(Book.self)).filter({$0.isReading})
    }
    
    // List of all the books that the user has finished reading.
    public var finishedBooks: [Book] {
        return Array(realm.objects(Book.self).filter({!$0.isReading}))
    }

    // Adds a new book to the list of books that the user is currently reading.
    public func addNewBook(book: Book) {
        try! realm.write {
            realm.add(book)
        }
    }
    
    // Indicates that the user is no longer reading the selected book.
    public func markAsFinished(book: Book) {
        try! realm.write {
            book.isReading = false
            book.whenCreated = Date()
        }
    }
    
    // Indicates that the user is currently reading the selected book.
    public func markAsReading(book: Book) {
        try! realm.write {
            book.isReading = true
            book.whenCreated = Date()
        }
    }
    
    // Indicates that the user would like to delete the selected book from the app's storage.
    public func delete(book: Book) {
        try! realm.write {
            realm.delete(book)
        }
    }
    
    public func getProgress(book: Book) -> Float {
        return Float(book.currentPage)/Float(book.totalPages)
    }
}
