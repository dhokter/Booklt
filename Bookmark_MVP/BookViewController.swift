//
//  ViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le, Kelli Mandel, Spencer Grant on 2/19/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import RealmSwift

class BookViewController: UIViewController, UITextFieldDelegate {

    enum DisplayMode {
        case newReading
        case details
        case newWishList
        case detailsWishList
    }

    let realm = try! Realm()
    
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    @IBOutlet weak var totalPageTextField: UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Color picker buttons
    @IBOutlet weak var redPicker: UIButton!
    @IBOutlet weak var purplePicker: UIButton!
    @IBOutlet weak var bluePicker: UIButton!
    @IBOutlet weak var greenPicker: UIButton!
    @IBOutlet weak var goldPicker: UIButton!
    
    // Rating star buttons and rating stack view
    @IBOutlet var ratingButtons: [UIButton]!
    @IBOutlet weak var ratingView: UIStackView!
    
    private var selectedColor = "red"
    private var userIsEditingTheBook = false
    
    // The stack view containing current and total pages view
    @IBOutlet weak var pageViews: UIStackView!
    // The stack view containing author textField and the line break
    @IBOutlet weak var authorView: UIStackView!
    
    var book: Book?
    var displayMode: DisplayMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoneButtonOnKeyboard()
        // Make the save button disabled if the title field is empty
        bookTitleTextField.addTarget(self, action: #selector(titleDidChange(textField:)), for: .editingChanged)
        
        switch displayMode! {
        case .newReading:
            prepareAddNewBook()
        case .details:
            prepareBookDetails()
        case .newWishList:
            prepareAddNewBook()
            pageViews.isHidden = true
        case .detailsWishList:
            prepareBookDetails()
            pageViews.isHidden = true
            ratingView.isHidden = true
        }
    }
    
    private func prepareBookDetails() {
        let book = self.book!
        // Update the information of the book to screen if the view is on BookDetails mode
        bookTitleTextField.text = book.title
        if book.author == "" {
            authorView.isHidden = true
        } else {
            authorTextField.text = book.author
        }
        currentPageTextField.text = String(describing: book.currentPage)
        totalPageTextField.text = String(describing: book.totalPages)
        
        highlightColorButtonFromString(bookColor: book.color)
        updateStarRating()
        
        // Make all textFields disabled if the view is in BookDetails mode
        bookTitleTextField.isEnabled = false
        authorTextField.isEnabled = false
        currentPageTextField.isEnabled = false
        totalPageTextField.isEnabled = false
        
        navigationItem.title = book.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTouched(_:)))
    }
    
    private func prepareAddNewBook() {
        // Hide the rating from user if they are creating a new book
        ratingView.isHidden = true
        bookTitleTextField.becomeFirstResponder() // Pop up the keyboard immediately so user can begin to type righ away when creating new book
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
    
    func titleDidChange(textField: UITextField) {
        var saveButton: UIBarButtonItem
        // Depends on whether the view is displaying BookDetails or AddBook, the save button will be assgined accordingly
        if self.book != nil {
            saveButton = navigationItem.rightBarButtonItem!
        } else {
            saveButton = self.saveButton
        }
        // Disable the save button on navigation bar if the title is empty
        if textField == bookTitleTextField {
            if textField.text == "" {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "addNewBook"?:
            book = Book(title: bookTitleTextField.text!, totalPages: Int(totalPageTextField.text!) ?? 0, currentPage: Int(currentPageTextField.text!) ?? 0, author: authorTextField.text!, whenCreated: Date(), color: selectedColor)
        default:
            return
        }
        
    }
    
    // Process of adding a new book:
    // 1. Making a new book from what user entered (using a method maybe, so all the field can be checked, this method return Book?,so it if there is any failed textfield entered, nil will be returned)
    // 2. Add the newly created book to the list allBooks in the BookManager, since this is newly created, put it in the displayed list as well.
    // 3. insertRow in the tableView for the new book
    // Return to the listbook view with the new book displayed
    
    
    @IBAction func colorSelected(_ sender: UIButton) {
        switch sender{
        case redPicker:
            selectedColor = "red"
        case purplePicker:
            selectedColor = "purple"
        case bluePicker:
            selectedColor = "blue"
        case greenPicker:
            selectedColor = "green"
        case goldPicker:
            selectedColor = "gold"
        default:
            return
        }
        highlightColorButton(sender: sender)
        // Update the color icon when selected if the view is in BookDetails mode
        if book != nil {
            try! realm.write {
                book?.color = selectedColor
            }
        }
    }
    
    private func highlightColorButton(sender: UIButton){
        let colorButtons = [redPicker, purplePicker, bluePicker, greenPicker, goldPicker]
        for button in colorButtons{
            if button != sender{
                button?.setImage(nil, for: UIControlState.normal)
            }
            else{
                button?.setImage(#imageLiteral(resourceName: "colorpicker_highlighted"), for: UIControlState.normal)
            }
        }
    }
    
    private func highlightColorButtonFromString(bookColor: String){
        switch bookColor{
        case "red":
            highlightColorButton(sender: redPicker)
        case "purple":
            highlightColorButton(sender: purplePicker)
        case "blue":
            highlightColorButton(sender: bluePicker)
        case "green":
            highlightColorButton(sender: greenPicker)
        case "gold":
            highlightColorButton(sender: goldPicker)
        default:
            return
        }
    }

    
    
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
    
    @IBAction func ratingChange(_ sender: UIButton) {
        switch sender{
        case ratingButtons[0]:
            if book?.rating != 1 {
                setRating(rate: 1)
            }
            else{
                setRating(rate: 0)
            }
        case ratingButtons[1]:
            setRating(rate: 2)
        case ratingButtons[2]:
            setRating(rate: 3)
        case ratingButtons[3]:
            setRating(rate: 4)
        case ratingButtons[4]:
            setRating(rate: 5)
        default:
            return
        }
        updateStarRating()
    }
    
    private func setRating(rate: Int){
        try! realm.write {
            book?.rating = rate
        }
    }
    
    private func updateStarRating(){
        let rating = book?.rating
        if rating != 0 {
            for i in 0...rating!-1{
                ratingButtons[i].setImage(#imageLiteral(resourceName: "star_closed"), for: UIControlState.normal)
            }
            if rating! < 5{
                for i in rating!...4{
                    ratingButtons[i].setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
                }
            }
        }
        else{
            for star in ratingButtons{
                star.setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
            }
        }
    }
    
    func editButtonTouched(_ sender: UIBarButtonItem) {
        if !userIsEditingTheBook {
            sender.title = "Save"
            authorView.isHidden = false
            // Make the keyboard appears immediately and focus on the title textField when user hit "Edit"
            // This code is used instead of becomeFirstResponder directly to guarantee a keyboard will popup
            // The reason for this should be found on http://stackoverflow.com/questions/27098097/becomefirstresponder-not-working-in-ios-8
            bookTitleTextField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.0)
        } else {
            sender.title = "Edit"
            // If the current page is being changed, then the book will become "most recent" in the tableView
            if book?.currentPage != Int(currentPageTextField.text!) {
                try! realm.write {
                    book?.whenCreated = Date()
                }
            }
            try! realm.write {
                book?.title = bookTitleTextField.text!
                book?.author = authorTextField.text!
                book?.totalPages = Int(totalPageTextField.text!) ?? 0
                book?.currentPage = Int(currentPageTextField.text!) ?? 0
            }
            currentPageTextField.text = book?.currentPage.description
            totalPageTextField.text = book?.totalPages.description
            navigationItem.title = book?.title
        }
        userIsEditingTheBook = !userIsEditingTheBook
        // Make sure the all text field is disabled or enabled relevant to the Save button's state
        bookTitleTextField.isEnabled = userIsEditingTheBook
        authorTextField.isEnabled = userIsEditingTheBook
        totalPageTextField.isEnabled = userIsEditingTheBook
        currentPageTextField.isEnabled = userIsEditingTheBook
    }


}
