//
//  BookManagerModel.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/27/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import Foundation
import UIKit

class BookManagerModel {
    private var bookStorageDict = [String : Book]()
    
    // Methods to load the new data into the book
    public func updateBookTitle(bookTitle: String, newBookTitle: String) {
        bookStorageDict[bookTitle]?.titleBook = newBookTitle
    }
    
    public func updateBookPageNumber(bookTitle: String, newPageNumber: Int) {
        bookStorageDict[bookTitle]?.pageNumber = newPageNumber
    }
    
    public func updateBookCurrentPage(bookTitle: String, newCurrentPage: Int) {
        bookStorageDict[bookTitle]?.currentPage = newCurrentPage
    }
    
    public func updateBookAuthor(bookTitle: String, newAuthor: String) {
        bookStorageDict[bookTitle]?.author = newAuthor
    }

    
//    public func updateBookCover(bookTitle: String, newCover: UI)
    
    // Method for getting a book from storage
    // Return an optional book in case the bookTitle is not in the storage
    public func getBook(bookTitle: String) -> Book? {
        if let aBook = bookStorageDict[bookTitle] {
            return aBook
        }
        return nil
    }
    
    public func getNumBook() -> Int {
        return bookStorageDict.count
    }
    
    
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
    }
}
