//
//  ViewController.swift
//  BookIt
//
//  Created by Duc Le, Kelli Mandel, Spencer Grant on 2/19/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import RealmSwift

// Converts the text in a TextField to Int as proper input for page numbers. (Prevents inadequate input from user by returning 0 by default)
func convertPageNumber(textField: UITextField) -> Int {
    guard let pageNumber = textField.text else {
        return 0
    }
    let numPage = Int(pageNumber) ?? 0
    return (numPage < 0) ? 0 : numPage
}

class BookViewController: UIViewController, UITextFieldDelegate {
    
    // Diferent states of BookViewController, each state corresponding to a different setting for determining what information to display.
    enum DisplayMode {
        case newReading
        case details
        case newWishList
        case detailsWishList
    }
    
    let realm = try! Realm()
    
    // UI elements containing information about a book
    @IBOutlet weak var bookTitleTextField:   UITextField!
    @IBOutlet weak var authorTextField:      UITextField!
    @IBOutlet weak var totalPageTextField:   UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    
    // Button allowing the user to decide when they want to start and finish editing book information.
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Color picker buttons
    @IBOutlet weak var redPicker:    UIButton!
    @IBOutlet weak var purplePicker: UIButton!
    @IBOutlet weak var bluePicker:   UIButton!
    @IBOutlet weak var greenPicker:  UIButton!
    @IBOutlet weak var goldPicker:   UIButton!
    
    // Rating star buttons and rating stack view
    @IBOutlet var ratingButtons:   [UIButton]!
    @IBOutlet weak var ratingView: UIStackView!

    // The stack view containing current and total pages view
    @IBOutlet weak var pageViews:       UIStackView!
    // Stack view containing current page textField and its line break
    @IBOutlet weak var currentPageView: UIStackView!
    // Stack view containing author textField and its line break
    @IBOutlet weak var authorView:      UIStackView!
    
    // Icon color of a book (Default to red)
    private var selectedColor        = "red"
    // Keeps track of when the user is editing the book
    private var userIsEditingTheBook = false
    
    var book: Book?
    var displayMode: DisplayMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonOnKeyboard()
        
        bookTitleTextField.addTarget(self, action: #selector(titleDidChange(textField:)), for: .editingChanged)     // Disable save button if title field is empty
        
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
            pageViews.isHidden  = true
            ratingView.isHidden = true
        }
    }
    
    // Prepares the scene if it is in details/detailsWishList mode
    private func prepareBookDetails() {
        let book                = self.book!
        bookTitleTextField.text = book.title
        
        if book.author == "" {                                      // Hide any fields left empty
            authorView.isHidden = true
        } else {
            authorTextField.text = book.author
        }
        
        if book.status == "completed" {                             // Hide current page if the book is completed
            currentPageView.isHidden = true
        } else {
            currentPageTextField.text = String(describing: book.currentPage)
        }
        totalPageTextField.text = String(describing: book.totalPages)
        
        highlightColorButtonFromString(bookColor: book.color)       // Display the icon color and rating of the book
        updateStarRating()
        
        // Disable all textFields if the view is in BookDetails mode
        bookTitleTextField.isEnabled   = false
        authorTextField.isEnabled      = false
        currentPageTextField.isEnabled = false
        totalPageTextField.isEnabled   = false
        
        navigationItem.title = book.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTouched(_:)))
    }
    
    // Prepares the scene if it is in newReading/newWishList mode.
    private func prepareAddNewBook() {
        ratingView.isHidden = true                  // Hide the rating from user if they are creating a new book
        bookTitleTextField.becomeFirstResponder()   // Pop up the keyboard immediately so user can begin to type right away when creating new book
    }
    
    // Go back to the book list screen and dismiss all changes made in Add book page.
    @IBAction func tochedCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Make sure the user can hit return and finish editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // The call back method for the bookTitleTextField if its content is changed
    func titleDidChange(textField: UITextField) {
        var saveButton: UIBarButtonItem
        
        if self.book != nil {                       // Save button shows when editing a book, but not when adding a new book.
            saveButton = navigationItem.rightBarButtonItem!
        } else {
            saveButton = self.saveButton
        }
        
        if textField == bookTitleTextField {        // Disable the save button on navigation bar if title is empty
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
            book = Book(title: bookTitleTextField.text!, totalPages: convertPageNumber(textField: totalPageTextField), currentPage: convertPageNumber(textField: currentPageTextField), author: authorTextField.text!, whenCreated: Date(), color: selectedColor)
        default:
            return
        }
        
    }
    
    // Method to pick a color for the book icon
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
        
        if book != nil {                        // Update the color icon when selected if the view is in BookDetails mode
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
    
    // Put a check on the current color of the book
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
    
    // Callback method when a user taps on a rating star
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
    
    // Fills in the star images according to the rating assigned to the book.
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
    
    // Checks prepare for editting/saving when the edit button in details mode is touched.
    func editButtonTouched(_ sender: UIBarButtonItem) {
        if !userIsEditingTheBook {
            sender.title = "Save"
            authorView.isHidden = false
            bookTitleTextField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.0)     // Ensure that the keyboard appear immediately and focus on     
                                                                                                        // the title textField when user hit "Edit".
                                                                                                        // Source: http://stackoverflow.com/questions/27098097/becomefirstresponder-not-working-in-ios-8
        } else {
            sender.title = "Edit"
            
            if book?.currentPage != convertPageNumber(textField: currentPageTextField) {        // If the current page is being changed, then the book will become 
                                                                                                // "most recent" in the tableView
                try! realm.write {
                    book?.whenCreated = Date()
                }
            }
            try! realm.write {
                book?.title       = bookTitleTextField.text!
                book?.author      = authorTextField.text!
                book?.totalPages  = convertPageNumber(textField: totalPageTextField)
                book?.currentPage = convertPageNumber(textField: currentPageTextField)
            }
            currentPageTextField.text = book?.currentPage.description
            totalPageTextField.text   = book?.totalPages.description
            navigationItem.title      = book?.title
        }
        userIsEditingTheBook = !userIsEditingTheBook
        
        // Make sure the all text fields are disabled or enabled depending on the Save button's state
        bookTitleTextField.isEnabled   = userIsEditingTheBook
        authorTextField.isEnabled      = userIsEditingTheBook
        totalPageTextField.isEnabled   = userIsEditingTheBook
        currentPageTextField.isEnabled = userIsEditingTheBook
    }
}
