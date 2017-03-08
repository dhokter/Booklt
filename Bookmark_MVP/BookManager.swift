//
//  BookManagerModel.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/27/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import Foundation
import UIKit

let bookManager = BookManager()

class BookManager {
    // List of all books in the inventory.
    var allBooks = [Book]()
    // List of all books being displayed.
    private var displayedBooks = [Book]()
    
    init() {
        loadInitialList()
    }

    // This code here to load some initial books into the list for testing the product.
    // Commented out after having the actual data.
    private func loadInitialList() {
        let theMartianImage = UIImage(named: "theMartian")
        let harryPotterImage = UIImage(named: "harryPotter")
        let theLostSymbolImage = UIImage(named: "theLostSymbol")
        
        guard let book1 = Book(title: "The Martian", totalPages: 400, cover: theMartianImage, currentPage: 380) else {
            fatalError("Cannot instantiate book1")
        }
        
        guard let book2 = Book(title: "Harry Potter and the Deathly hallows", totalPages: 1200, cover: harryPotterImage, currentPage: 265) else {
            fatalError("Cannot instantiate book2")
        }
        
        guard let book3 = Book(title: "The Lost Symbol", totalPages: 1300, cover: theLostSymbolImage, currentPage: 780) else {
            fatalError("Cannot instantiate book3")
        }
        displayedBooks += [book1, book2, book3]
        allBooks = displayedBooks
    }
    
    public func getDislayedBooks() -> [Book] {
        //... The logic is not complete, it should only return the current reading list book
        // return all books for now as testing purpose
        return displayedBooks
    }

    // Adding a newly created book to the inventory, and also add it to displayedBook list as well
    public func addNewBook(book: Book) {
        allBooks.append(book)
        displayedBooks.append(book)
    }
    
    public func getNumDisplayedBook() -> Int {
        // The logic here is to return the count of list book that being displayed, not the total number of book in inventory
        return displayedBooks.count
    }
    
    public func getNumBook() -> Int {
        // Return the total number of books in the inventory
        return allBooks.count
    }
    
    public func markAsFinished(book: Book) {
        // Remove by filter the list of displayed books
        // Using !== because of comparing object
        displayedBooks = displayedBooks.filter({$0 !== book})
    }
}
