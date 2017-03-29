//
//  BookDetailsViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/2/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import RealmSwift

class BookDetailsViewController: UIViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var totalPagesTextField: UITextField!
    @IBOutlet weak var currentPageTextField: UITextField!
    @IBOutlet weak var personalNotesTextView: UITextView!
    
    //Star rating buttons
    @IBOutlet weak var oneStar: UIButton!
    @IBOutlet weak var twoStar: UIButton!
    @IBOutlet weak var threeStar: UIButton!
    @IBOutlet weak var fourStar: UIButton!
    @IBOutlet weak var fiveStar: UIButton!
    
    var book: Book?
    var userIsEditingTheBook = false
    
    // (Spencer) Default background for the personalNotes section when uneditable
    let greyBackgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    
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
            personalNotesTextView.text = book.personalNotes
        }
        updateStarRating()
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Changes the display and function when the user hits "Edit"
    @IBAction func editButtonTouched(_ sender: UIBarButtonItem) {
        if !userIsEditingTheBook {
            sender.title = "Save"
            personalNotesTextView.backgroundColor = UIColor.white               // (Spencer) Sets the color of the personalNotes section to be white when editable
        } else {
            sender.title = "Edit"
            try! realm.write {
                book?.title = titleTextField.text!
                book?.author = authorTextField.text!
                book?.totalPages = Int(totalPagesTextField.text!) ?? 0
                book?.currentPage = Int(currentPageTextField.text!) ?? 0
                book?.personalNotes = personalNotesTextView.text!               // (Spencer) Save and store the user's personal notes
                personalNotesTextView.backgroundColor = greyBackgroundColor     // (Spencer) Sets the color of the personalNotes section to be grey when uneditable
            }
            navigationItem.title = book?.title
        }
        userIsEditingTheBook = !userIsEditingTheBook
        
        titleTextField.isEnabled = userIsEditingTheBook
        authorTextField.isEnabled = userIsEditingTheBook
        totalPagesTextField.isEnabled = userIsEditingTheBook
        currentPageTextField.isEnabled = userIsEditingTheBook
        personalNotesTextView.isEditable = userIsEditingTheBook                 // (Spencer) Allow user to edit their personal notes only after they have hit "Edit"
    }
    
    // Adds the done button to the number pad. 
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
        self.totalPagesTextField.inputAccessoryView = doneToolbar
    }
    
    // Gets rid of the number pad when the user hits "Done"
    public func doneButtonAction() {
        currentPageTextField.resignFirstResponder()
        totalPagesTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func ratingChange(_ sender: UIButton) {
        switch sender{
        case oneStar:
            if book?.rating != 1 {
                setRating(rate: 1)
            }
            else{
                setRating(rate: 0)
            }
        case twoStar:
            setRating(rate: 2)
        case threeStar:
            setRating(rate: 3)
        case fourStar:
            setRating(rate: 4)
        case fiveStar:
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
        let stars = [oneStar, twoStar, threeStar, fourStar, fiveStar]
        if rating != 0 {
            for i in 0...rating!-1{
                stars[i]?.setImage(#imageLiteral(resourceName: "star_closed"), for: UIControlState.normal)
            }
            if rating! < 5{
                for i in rating!...4{
                    stars[i]?.setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
                }
            }
        }
        else{
            for star in stars{
                star?.setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
            }
        }
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
