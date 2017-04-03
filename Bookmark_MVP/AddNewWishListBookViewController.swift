//
//  AddNewWishListBook.swift
//  Bookmark_MVP
//
//  Created by Spencer Grant on 3/28/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class AddNewWishListBookViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Color picker buttons
    @IBOutlet weak var redPicker: UIButton!
    @IBOutlet weak var purplePicker: UIButton!
    @IBOutlet weak var bluePicker: UIButton!
    @IBOutlet weak var greenPicker: UIButton!
    @IBOutlet weak var goldPicker: UIButton!
    
    private var selectedColor = "red"
    
    // we should links or the buttons of choosing colors to ViewController?
    
    var newBook: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Method to get back the list book screen and dismiss all changes made in Add book page.
    
    @IBAction func touchedCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Make sure the user can hit return and finished editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // TODO: 2 functions below provide the same result and it is unecessary to have both. Consider delete one of them. Suggest to delete shouldPerformSegue
    // Disable the SAVE button until there is some content in the bookTitleTextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === titleTextField {
            if string != "" {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        }
        
        return true
    }
    
    // Check if the book is created correctly with all required information before transfer to the WishlistBooksViewController
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "AddWishlistSegue":
            if titleTextField.text! == "" {
                // TODO: Create an alert notify the problem for user.
                return false
            }
            return true
        default:
            return true
        }
        
    }
    
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
    }
    
    private func highlightColorButton(sender: UIButton){
        let colorButtons = [redPicker, purplePicker, bluePicker, greenPicker, goldPicker]
        for button in colorButtons {
            if button != sender {
                button?.setImage(nil, for: UIControlState.normal)
            }
            else {
                button?.setImage(#imageLiteral(resourceName: "colorpicker_highlighted"), for: UIControlState.normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    // Process of adding a new book:
    // 1. Making a new book from what user entered (using a method maybe, so all the field can be checked, this method return Book?,so it if there is any failed textfield entered, nil will be returned)
    // 2. Add the newly created book to the list allBooks in the BookManager, since this is newly created, put it in the displayed list as well.
    // 3. insertRow in the tableView for the new book
    // Return to the listbook view with the new book displayed
}
