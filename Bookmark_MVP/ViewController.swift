//
//  ViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le, Kelli Mandel, Spencer Grant on 2/19/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pageNumberTextField: UITextField!
    @IBOutlet weak var bookTitleTextField: UITextField!
    
    // A built-in function, get called when user touch somewhere in the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // A built-in function for UITextField, set the done editing status to be true.
        pageNumberTextField.endEditing(true)
        bookTitleTextField.isEnabled = false
        print(bookTitleTextField.state)
    }
    // If the user touch the edit button, set the book title to be editable
    @IBAction func editButtonTouch(_ sender: UIBarButtonItem) {
        bookTitleTextField.isEnabled = true
    }
}

