//
//  ViewController.swift
//  BookIt
//
//  Created by Duc Le, Kelli Mandel, Spencer Grant on 2/19/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import RealmSwift

// Method to convert the text in a TextField to Int as proper input for page numbers
// Prevent in adequate input from user by return 0 as default
func convertPageNumber(textField: UITextField) -> Int {
    guard let pageNumber = textField.text else {
        return 0
    }
    let numPage = Int(pageNumber) ?? 0
    return (numPage < 0) ? 0 : numPage
}

class BookViewController: UIViewController, UITextFieldDelegate {

    // Diferent states of BookViewController, each state corresponding to a different setting for views and features
    enum DisplayMode {
        case newReading
        case details
        case newWishList
        case detailsWishList
    }

    let realm = try! Realm()
    
    // UI elements containing information of a book
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var totalPageTextField: UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    
    // Save button for editting if the scene is in details/detailsWishList mode
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
    
    // Initial value for a new book's icon
    private var selectedColor = "red"
    // Initial state if the scene is in details/detailsWishList mode
    private var userIsEditingTheBook = false
    
    // The stack view containing current and total pages view
    @IBOutlet weak var pageViews: UIStackView!
    // The stack view containing current page textField and the line break
    @IBOutlet weak var currentPageView: UIStackView!
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
    
    // Method to prepare the scene if it is in details/detailsWishList mode
    private func prepareBookDetails() {
        let book = self.book!
        bookTitleTextField.text = book.title
        // Hiding optional information if it is empty
        if book.author == "" {
            authorView.isHidden = true
        } else {
            authorTextField.text = book.author
        }
        // Hiding current page if the book is completed, so the scene is not counter intuitive
        if book.status == "completed" {
            currentPageView.isHidden = true
        } else {
            currentPageTextField.text = String(describing: book.currentPage)
        }
        totalPageTextField.text = String(describing: book.totalPages)
        
        // Display the corresponding icon color and rating of the book
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
    
    // Method to prepare the scene if it is in newReading/newWishList mode.
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
    
    // The call back method for the bookTitleTextField if its content is changed
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
    
    // Put a tick on the current color of the book
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
    
    // Callback method when a user touch on a rating star
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
    
    // When the edit button in details mode is touched, this function is called to check prepare for editting/saving
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
            if book?.currentPage != convertPageNumber(textField: currentPageTextField) {
                try! realm.write {
                    book?.whenCreated = Date()
                }
            }
            try! realm.write {
                book?.title = bookTitleTextField.text!
                book?.author = authorTextField.text!
                book?.totalPages = convertPageNumber(textField: totalPageTextField)
                book?.currentPage = convertPageNumber(textField: currentPageTextField)
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
