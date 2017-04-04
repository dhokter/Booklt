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
    
    //Star rating buttons
    @IBOutlet var ratingStars: [UIButton]!
    
    //Color picker buttons
    @IBOutlet weak var redPicker: UIButton!
    @IBOutlet weak var purplePicker: UIButton!
    @IBOutlet weak var bluePicker: UIButton!
    @IBOutlet weak var greenPicker: UIButton!
    @IBOutlet weak var goldPicker: UIButton!
    
    
    private var selectedColor = "red"
    
    
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
            selectedColor = book.color
            highlightColorButtonFromString(bookColor: selectedColor)
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

        } else {
            sender.title = "Edit"
            try! realm.write {
                book?.title = titleTextField.text!
                book?.author = authorTextField.text!
                book?.totalPages = Int(totalPagesTextField.text!) ?? 0
                book?.currentPage = Int(currentPageTextField.text!) ?? 0
            }
            navigationItem.title = book?.title
        }
        userIsEditingTheBook = !userIsEditingTheBook
        
        titleTextField.isEnabled = userIsEditingTheBook
        authorTextField.isEnabled = userIsEditingTheBook
        totalPagesTextField.isEnabled = userIsEditingTheBook
        currentPageTextField.isEnabled = userIsEditingTheBook
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
        try! realm.write {
            book?.color = selectedColor
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
    
    
    @IBAction func ratingChange(_ sender: UIButton) {
        switch sender{
        case ratingStars[0]:
            if book?.rating != 1 {
                setRating(rate: 1)
            }
            else{
                setRating(rate: 0)
            }
        case ratingStars[1]:
            setRating(rate: 2)
        case ratingStars[2]:
            setRating(rate: 3)
        case ratingStars[3]:
            setRating(rate: 4)
        case ratingStars[4]:
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
                ratingStars[i].setImage(#imageLiteral(resourceName: "star_closed"), for: UIControlState.normal)
            }
            if rating! < 5{
                for i in rating!...4{
                    ratingStars[i].setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
                }
            }
        }
        else{
            for star in ratingStars{
                star.setImage(#imageLiteral(resourceName: "star_open"), for: UIControlState.normal)
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
