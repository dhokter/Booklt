//
//  BookTableViewCell.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleBookView: UILabel!
    @IBOutlet weak var progressLabelView: UILabel!
    @IBOutlet weak var currentPageView: UITextField!
    @IBOutlet weak var progressBarView: UIProgressView!
    
    // The instance of the book the cell is displaying
    var bookDisplay: Book? {
        // As this book is set, then the following display will set up
        didSet {
            if let book = bookDisplay {
                addDoneButtonOnKeyboard()
                titleBookView.text = book.title
                coverImageView.image = book.cover
                currentPageView.text = String(book.currentPage)
                currentPageView.delegate = self
                progressBarView.progress = Float(book.currentPage) / Float(book.totalPages)
                progressLabelView.text = String(Int(Float(book.currentPage)*100 / Float(book.totalPages)))+"%"
            }
        }
    }
    
    // When user choose another textfield while editing one, the current one will still be updated (endEditing)
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTheCell()
    }
    
    // Function to update the cell from the text field
    @objc private func updateTheCell() {
        // Update the book of the cell
        currentPageView.resignFirstResponder()
        bookDisplay?.currentPage = Int(self.currentPageView.text!)!
        progressBarView.progress = Float((bookDisplay?.currentPage)!) / Float((bookDisplay?.totalPages)!)
        let progress = Float((bookDisplay?.currentPage)!)*100 / Float((bookDisplay?.totalPages)!)
        progressLabelView.text = String(Int(progress))+"%"
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
