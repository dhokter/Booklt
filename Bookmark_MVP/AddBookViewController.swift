//
//  ViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le, Kelli Mandel, Spencer Grant on 2/19/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var photoPickerView: UIImageView!
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var totalPageTextField: UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    
    // Method to get back the list book screen and dismiss all changes made in Add book page.
    @IBAction func tochedCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Make sure the user can hit return and finished editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
