//
//  BookTableViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ReadingBooksTableViewController: UITableViewController, MGSwipeTableCellDelegate {
    
    // List of books to be displayed on screen, with value passed by the bookManager
    private var books = [Book]()
    private var filterType: FilterType = .chronological(bookManager.sortBooksChronologically)
    
    //(Kelli) Sort method buttons
    @IBOutlet weak var sortType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // The function to reload the data if the view appear again by the BACK button of some other ViewController
    override func viewWillAppear(_ animated: Bool) {
        books = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        tableView.reloadData()
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ReadingBooksTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReadingBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of BookTableViewCell")
        }
        cell.delegate = self
        let book = books[indexPath.row]
        cell.book = book    // Loads the information in the book to the cell to display
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MoveToBookDetailsSegue", sender: self)
    }
    
    // Prepare the data before a segue. Divided by cases, each cases using Segue Identifier to perform appropriate action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "MoveToBookDetailsSegue"?:
            guard let destination = segue.destination as? BookDetailsViewController else {     // Pass the book instance of the cell to the ViewController to display
                return
            }
            destination.book = books[(tableView.indexPathForSelectedRow?.row)!]
        default: break
            
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        let indexPath = self.tableView.indexPath(for: cell)
        let book = books[(indexPath?.row)!]
        
        if direction == MGSwipeDirection.leftToRight {
            return [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {(sender: MGSwipeTableCell)->Bool in
                self.confirmDeleteBook(indexPath: indexPath!, book: book)
                return false
            })]
        } else {
            return [MGSwipeButton(title: "Mark as Done", backgroundColor: .green, callback: {(sender: MGSwipeTableCell)->Bool in
                bookManager.markAsFinished(book: book)
                self.deleteAndUpdateCells(indexPath: indexPath!)
                return false
            })]
        }
    }
    
    
    // The function the for unwind segue from the AddBookView.
    @IBAction func addNewBookAndUnwind(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddBookViewController {
            bookManager.addNewBook(book: sourceViewController.newBook!)
            books = bookManager.readingBooks
            let newIndexPath = IndexPath(row: books.count-1, section: 0)        // Creates a new cell for the book
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
            
            tableView.reloadData()
        }
    }
    
    //(Kelli) Activated when user switches between "A-Z" and "Date" sort methods
    @IBAction private func sortTypeChanged(_ sender: Any) {
        switch sortType.selectedSegmentIndex
        {
        case 0:                             // "A-Z" is selected
            filterType = .alphabetical(bookManager.sortBooksAlphabetically)
        case 1:                             // "Date" is selected
            filterType = .chronological(bookManager.sortBooksChronologically)
        case 2:                             // "Progress ↑" is selected
            filterType = .increasingProgress(bookManager.sortBooksByIncreasingProgress)
        case 3:                             // "Progress ↓" is selected
            filterType = .increasingProgress(bookManager.sortBooksByDecreasingProgress)
        default:
            break
        }
        books = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        tableView.reloadData()
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    private func deleteAndUpdateCells(indexPath: IndexPath) {
        books = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    /*
     //     Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the tableview, but the book will still be in inventory
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    private func confirmDeleteBook(indexPath: IndexPath, book: Book) {
        let alert = UIAlertController(title: "Please Confirm", message: "Are you sure you want to delete this book?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, delete it", style: .destructive, handler: {(action: UIAlertAction) in
            bookManager.delete(book: book)
            self.deleteAndUpdateCells(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            self.tableView.setEditing(false, animated: true)
        }))
        
        self.present(alert, animated: false, completion: nil)
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
