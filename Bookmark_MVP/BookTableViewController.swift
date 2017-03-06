//
//  BookTableViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class BookTableViewController: UITableViewController {
    
    // Create a book manager model
    let bookManager = BookManager()
    
    // List of books to be displayed on screen, with value passed by the bookManager
    var books = [Book]()
    
    //Checks sort method — true if alphabetical, false if by date
    var isAlphabetical = false
    
    //(Kelli) Sort method buttons
    @IBOutlet weak var sortType: UISegmentedControl!
    
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
        cell.book = book

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MoveToBookDetailsSegue", sender: self)
    }
    
    // Prepare the data before a segue. Divided by cases, each cases using Segue Identifier to perform appropriate action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "MoveToBookDetailsSegue":
            // Pass the book instance of the cell to the ViewController for displaying
            guard let destination = segue.destination.childViewControllers[0] as? BookDetailsViewController else {
                return
            }
            destination.book = books[(tableView.indexPathForSelectedRow?.row)!]
        default: break
            
        }
    }
    
    // The function to reload the data if the view appear again by the BACK button of some other ViewController
    override func viewWillAppear(_ animated: Bool) {
        if isAlphabetical{
            sortBooksAlphabetically()
        }
        tableView.reloadData()
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
            if isAlphabetical{
                sortBooksAlphabetically()
            }
            tableView.reloadData()
        }
    }
    
    //(Kelli) Activated when user switches between "A-Z" and "Date" sort methods
    @IBAction func sortTypeChanged(_ sender: Any) {
        switch sortType.selectedSegmentIndex
        {
        case 0:
            isAlphabetical = true
            sortBooksAlphabetically()
        case 1:
            isAlphabetical = false
        default:
            break
        }
        tableView.reloadData()
    }
   
    
    private func sortBooksAlphabetically(){
        books = books.sorted(by: {$0.title < $1.title })
        //books = books.sorted(by: {makeAlphabetizableTitle(book: $0) < makeAlphabetizableTitle(book: $1)})
    }
    
    
//(Kelli) WIP function for ignoring "the" substring when alphabetizing
    
//    private func makeAlphabetizableTitle(book : Book) -> String{
//        var alphebetizable = book.title
//        let ignoreCase = alphebetizable.lowercased()
//        let index = ignoreCase.index(ignoreCase.startIndex, offsetBy: 3)
//        let firstThreeLetters = ignoreCase.substring(to: index)
//        if firstThreeLetters == "the "{
//            alphebetizable = ignoreCase.substring(from: index)
//        }
//        return alphebetizable
//    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the tableview, but the book will still be in inventory
            bookManager.markAsFinished(book: books[indexPath.row])
            books.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Change the title of Delete button to Mark as Done.
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Mark as Done"
    }
    

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
