//
//  BookDetailsViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/2/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class BookDetailsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var totalPagesTextField: UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    
    var book: Book?
    var userIsEditingTheBook = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonOnKeyboard()
        
        // Do any additional setup after loading the view.
        if let book = self.book {
            navigationItem.title = book.title
            titleTextField.text = book.title
            authorTextField.text = book.author
            totalPagesTextField.text = String(book.totalPages)
            currentPageTextField.text = String(book.currentPage)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Touch edit button function
    @IBAction func editButtonTouched(_ sender: UIBarButtonItem) {
        if !userIsEditingTheBook {
            sender.title = "Save"
        } else {
            sender.title = "Edit"
            book?.title = titleTextField.text!
            book?.author = authorTextField.text!
            book?.totalPages = Int(totalPagesTextField.text!) ?? 0
            book?.currentPage = Int(currentPageTextField.text!) ?? 0
        }
        userIsEditingTheBook = !userIsEditingTheBook
        
        titleTextField.isEnabled = userIsEditingTheBook
        authorTextField.isEnabled = userIsEditingTheBook
        totalPagesTextField.isEnabled = userIsEditingTheBook
        currentPageTextField.isEnabled = userIsEditingTheBook
        
    }
    // Code for adding the done button on the number pad keyboad. Source URL: http://stackoverflow.com/questions/28338981/how-to-add-done-button-to-numpad-in-ios-8-using-swift
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
        self.totalPagesTextField.inputAccessoryView = doneToolbar
    }
    
    public func doneButtonAction() {
        currentPageTextField.resignFirstResponder()
        totalPagesTextField.resignFirstResponder()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
