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
let realm = try! Realm()

class BookManager {
    // List of all books in the inventory.
    public var allBooks: [Book] {
        get {
            return Array(realm.objects(Book.self))
        }
        set {
            self.allBooks = newValue
        }
    }
    
    // List of all books being displayed.
    public var displayedBooks: [Book] {
        get {
            return Array(realm.objects(Book.self))
        }
        set {
            self.displayedBooks = newValue
        }
    }

    public func addNewBook(book: Book) {
        try! realm.write {
            realm.add(book)
            allBooks.append(book)
            displayedBooks.append(book)
            
        }
    }
    
    public func markAsFinished(book: Book) {
        try! realm.write {
            realm.delete(book)
        }
    }
}
