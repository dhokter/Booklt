//
//  BookTableViewCell.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import RealmSwift

class BookTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleBookView: UILabel!
    @IBOutlet weak var progressLabelView: UILabel!
    @IBOutlet weak var currentPageView: UITextField!
    @IBOutlet weak var progressBarView: UIProgressView!
    
    // The instance of the book the cell is displaying
    // As this book is set, then the following display will set up
    var book: Book? {
        didSet {
            if let book = self.book {
                addDoneButtonOnKeyboard()
                titleBookView.text = book.title
                currentPageView.text = String(book.currentPage)
                currentPageView.delegate = self
                progressBarView.progress = Float(book.currentPage) / Float(book.totalPages)
                progressLabelView.text = String(Int(Float(book.currentPage)*100 / Float(book.totalPages)))+"%"
            }
        }
    }
    
    // If the user is editing one text field and then selects another, the current one will be updated.
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTheCell()
    }
    
    // Updates the book information and the contents of the cell when the user changes the current page number
    @objc private func updateTheCell() {
        currentPageView.resignFirstResponder()
        if let book = self.book {
            try! realm.write {
                book.currentPage = Int(self.currentPageView.text!)!
            }
            progressBarView.progress = Float((book.currentPage)) / Float((book.totalPages))
            let progress = Float((book.currentPage))*100 / Float((book.totalPages))
            progressLabelView.text = String(Int(progress))+"%"
        }
    }
    
    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Configure the view for the selected state
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Code for adding the done button on the number pad keyboad. Source URL: http://stackoverflow.com/questions/28338981/how-to-add-done-button-to-numpad-in-ios-8-using-swift
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(updateTheCell))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.currentPageView.inputAccessoryView = doneToolbar
    }
}
