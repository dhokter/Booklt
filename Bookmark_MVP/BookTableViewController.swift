//
//  BookTableViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class BookTableViewController: UITableViewController, UITextFieldDelegate {
    
    // Create a book manager model
    let bookManager = BookManager()
    
    // List of books to be displayed on screen, with value passed by the bookManager
    var books = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = bookManager.getDislayedBooks()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookManager.getNumDisplayedBook()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BookTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell else {
            fatalError("The dequeued cell is not an instance of BookTableViewCell")
        }
        
        let book = books[indexPath.row]
        
        // Loading the information in the book to the cell to display
        cell.bookDisplay = book
        cell.currentPageView.delegate = self
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    // Function for currentPage textfield resign from first reponder if the user hit enter.
    // This function is not working with numberpad.
    // This function now working for user entered new data. Now as long as user hit return, the new data will be display.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let cell = textField.superview?.superview as? BookTableViewCell else {
            fatalError("Error with configure the BookTableViewCell")
        }
        updateTheCell(updatedCell: cell)
        return true
    }
    
    // When user switch directly from textfield to textfield and not hit Return, the currentpage will still be updated
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let cell = textField.superview?.superview as? BookTableViewCell else {
            fatalError("Error with configure the BookTableViewCell")
        }
        updateTheCell(updatedCell: cell)
    }
    
    // Function to update the cell from the text field
    private func updateTheCell(updatedCell: BookTableViewCell) {
        if let bookBeingUpdated = updatedCell.bookDisplay {
            // Update the book of the cell
            bookBeingUpdated.currentPage = Int(updatedCell.currentPageView.text!)!
            updatedCell.progressBarView.progress = Float(bookBeingUpdated.currentPage) / Float(bookBeingUpdated.totalPages)
            updatedCell.progressLabelView.text = String(Int(Float(bookBeingUpdated.currentPage)*100 / Float(bookBeingUpdated.totalPages)))+"%"
        }
        self.tableView.reloadData()
    }
    
    
    // The function the for unwind segue from the AddBookView.
    @IBAction func addNewBookAndUnwind(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddBookViewController {
            // Add the new book passed by the AddBookView to the storage, and generate the new list of displayed books.
            bookManager.addNewBook(book: sourceViewController.newBook!)
            books = bookManager.getDislayedBooks()
            // Creating new cell for the book
            let newIndexPath = IndexPath(row: bookManager.getNumDisplayedBook()-1, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
        }
    }

        /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
