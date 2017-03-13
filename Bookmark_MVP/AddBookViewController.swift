//
//  ViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le, Kelli Mandel, Spencer Grant on 2/19/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var totalPageTextField: UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    
    var newBook: Book?
    
    override func viewDidLoad() {
        addDoneButtonOnKeyboard()
    }
    
    // Method to get back the list book screen and dismiss all changes made in Add book page.
    @IBAction func tochedCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Make sure the user can hit return and finished editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        newBook = Book(title: bookTitleTextField.text!, totalPages: Int(totalPageTextField.text!)!, currentPage: Int(currentPageTextField.text!)!, author: authorTextField.text!, whenCreated: Date(timeIntervalSinceNow: 0))
    }
    
    // Process of adding a new book:
    // 1. Making a new book from what user entered (using a method maybe, so all the field can be checked, this method return Book?,so it if there is any failed textfield entered, nil will be returned)
    // 2. Add the newly created book to the list allBooks in the BookManager, since this is newly created, put it in the displayed list as well.
    // 3. insertRow in the tableView for the new book
    // Return to the listbook view with the new book displayed
    
    
    // Adds the done button to the number pad
    // Source URL: http://stackoverflow.com/questions/28338981/how-to-add-done-button-to-numpad-in-ios-8-using-swift
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.currentPageTextField.inputAccessoryView = doneToolbar
        self.totalPageTextField.inputAccessoryView   = doneToolbar
    }
    
    // Gets rid of the number pad when the user hits "Done"
    func doneButtonAction() {
        self.currentPageTextField.resignFirstResponder()
        self.totalPageTextField.resignFirstResponder()
    }
}
