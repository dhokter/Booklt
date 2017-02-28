//
//  BookManagerModel.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/27/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import Foundation
import UIKit

class BookManager {
    private var allBooks = [Book]()
    
    init() {
        loadInitialList()
    }
    
    
    public func getNumBook() -> Int {
        return allBooks.count
    }
    
    // This code here to load some initial books into the list for testing the product.
    // Commented out after having the actual data.
    private func loadInitialList() {
        let theMartianImage = UIImage(named: "theMartian")
        let harryPotterImage = UIImage(named: "harryPotter")
        let theLostSymbolImage = UIImage(named: "theLostSymbol")
        
        guard let book1 = Book(titleBook: "The Martian", pageNumber: 400, bookCover: theMartianImage, currentPage: 380) else {
            fatalError("Cannot instantiate book1")
        }
        
        guard let book2 = Book(titleBook: "Harry Potter and the Deathly hallows", pageNumber: 1200, bookCover: harryPotterImage, currentPage: 265) else {
            fatalError("Cannot instantiate book2")
        }
        
        guard let book3 = Book(titleBook: "The Lost Symbol", pageNumber: 1300, bookCover: theLostSymbolImage, currentPage: 780) else {
            fatalError("Cannot instantiate book3")
        }
        
        allBooks += [book1, book2, book3]
    }
    
    public func getDislayedBooks() -> [Book] {
        //... The logic is not complete, it should only return the current reading list book
        // return all books for now as testing purpose
        return allBooks
    }
}
