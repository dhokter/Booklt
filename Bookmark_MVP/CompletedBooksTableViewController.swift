//
//  AllBooksTableViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/7/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class CompletedBooksTableViewController: UITableViewController, MGSwipeTableCellDelegate {
    
    private var books = [Book]()
    private var filterType: FilterType = .chronological
    
    @IBOutlet weak var allSortType: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Reload the data of table to make it updated with changes in books (if any).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        books = bookManager.sortBooks(books: bookManager.finishedBooks, filter: filterType)
        self.tableView.reloadData()
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedBooksTableViewCell", for: indexPath) as? CompletedBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of AllBookTableViewCell")
        }
        cell.book = books[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    // Select a book to move to its details page.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CompletedToBookDetailsSegue", sender: self)
    }
    
    // Prepare for the BookDetailView before perform the segue to it.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CompletedToBookDetailsSegue"?:
            guard let destination = segue.destination as? BookDetailsViewController else {
                return
            }
            destination.book = books[(tableView.indexPathForSelectedRow?.row)!]
        default:
            return
        }
    }
    
    @IBAction func sortTypeChanged(_ sender: UISegmentedControl) {
        switch allSortType.selectedSegmentIndex
        {
        case 0:
            filterType = .alphabetical
        case 1:
            filterType = .chronological
        default:
            break
        }
        books = bookManager.sortBooks(books: bookManager.finishedBooks, filter: filterType)
        tableView.reloadData()
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        let indexPath = self.tableView.indexPath(for: cell)
        let book = books[(indexPath?.row)!]
        
        if direction == MGSwipeDirection.leftToRight {
            return [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {(sender: MGSwipeTableCell) -> Bool in
                self.confirmDeleteBook(indexPath: indexPath!, book: book)
                return false
            })]
        } else {
            return [MGSwipeButton(title: "Mark as Reading", backgroundColor: .green, callback: {(sender: MGSwipeTableCell) -> Bool in
                bookManager.markAsReading(book: book)
                self.deleteAndUpdateCells(indexPath: indexPath!)
                return false
            })]
        }
    }
    
    private func deleteAndUpdateCells(indexPath: IndexPath) {
        books = bookManager.sortBooks(books: bookManager.finishedBooks, filter: filterType)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    private func confirmDeleteBook(indexPath: IndexPath, book: Book) {
        let alert = UIAlertController(title: "Please Confirm", message: "Are you sure you want to delete this book?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, delete", style: .destructive, handler: {(action: UIAlertAction) in
            bookManager.delete(book: book)
            self.deleteAndUpdateCells(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            let cell = self.tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
            cell.hideSwipe(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

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
