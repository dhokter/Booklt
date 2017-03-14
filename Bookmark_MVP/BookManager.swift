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
    
    //(Kelli) Finds any book with a leading "the " that we would like to ignore for the purpose of alphabetizing, and ignores it.
    private func makeAlphabetizableTitle(book : Book) -> String{
        
        var alphebetizable = book.title.lowercased()
        
        if alphebetizable.characters.count > 4{
            let index = alphebetizable.index(alphebetizable.startIndex, offsetBy: 4)
            let firstThreeLetters = alphebetizable.substring(to: index)
            if firstThreeLetters == "the "{
                alphebetizable = alphebetizable.substring(from: index)
            }
        }
        return alphebetizable
    }
    
    // Query displayed books from Realm and sort them alphabetically, A to Z
    func sortBooksAlphabetically(books: [Book]) -> [Book]{
        return books.sorted(by: {makeAlphabetizableTitle(book: $0) < makeAlphabetizableTitle(book: $1)})
    }
    
    // Query displayed books from Realm and sort them by date created, from earliest to most recent
    func sortBooksChronologically(books: [Book]) -> [Book]{
        return books.sorted(by: {$0.whenCreated > $1.whenCreated})
    }
    
    func sortBooksByIncreasingProgress(books: [Book]) -> [Book]{
        return books.sorted(by: {bookManager.getProgress(book: $0) < bookManager.getProgress(book: $1)})
    }
    
    func sortBooksByDecreasingProgress(books: [Book]) -> [Book]{
        return books.sorted(by: {bookManager.getProgress(book: $0) > bookManager.getProgress(book: $1)})
    }
    
    
}
