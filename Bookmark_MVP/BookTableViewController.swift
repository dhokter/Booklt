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
    let bookManager = BookManagerModel()
    
    // This is just to make sure there will be no error display
    // TODO: REPLACE THIS WITH THE LIST FROM THE MODEL bookManager
    var listBook = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadInitialList()

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
        return bookManager.getNumBook()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BookTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell else {
            fatalError("The dequeued cell is not an instance of BookTableViewCell")
        }
        
        // TODO: How to loop through the listbook by index, where listbook in the model is a dictionary
        let aBook = listBook[indexPath.row]
        
        // Loading the information in the book to the cell to display
        cell.titleBookView.text = aBook.titleBook
        cell.coverImageView.image = aBook.bookCover
        cell.currentPageView.text = String(aBook.currentPage)
        cell.currentPageView.delegate = self
        cell.progressBarView.progress = Float(aBook.currentPage) / Float(aBook.pageNumber)
        cell.progressLabelView.text = String(Int(Float(aBook.currentPage)*100 / Float(aBook.pageNumber)))+"%"

        // Configure the cell...

        return cell
    }
    
    // After entering the new currentPage number, user can touch on the book to get it updated.
    // TODO: Ask Paul how to get a cell given only knowing its subview textfield.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    // Function for currentPage textfield resign from first reponder if the user hit enter.
    // This function is not working with numberpad.
    // This function now working for user entered new data. Now as long as user hit return, the new data will be display.
    // TODO: Ask Paul for number pad
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let cell = textField.superview?.superview as? BookTableViewCell else {
            fatalError("Error with configure the BookTableViewCell")
        }
        var aBook: Book
        for book in listBook {
            if book.titleBook == cell.titleBookView.text! {
                aBook = book
                book.titleBook = cell.titleBookView.text!
                book.currentPage = Int(cell.currentPageView.text!)!
                cell.progressBarView.progress = Float(aBook.currentPage) / Float(aBook.pageNumber)
                cell.progressLabelView.text = String(Int(Float(aBook.currentPage)*100 / Float(aBook.pageNumber)))+"%"
            }
        }
        self.tableView.reloadData()

        return true
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
