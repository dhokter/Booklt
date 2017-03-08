//
//  AllBooksTableViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/7/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class AllBooksTableViewController: UITableViewController {
    
//    var bookManager = BookManager()
    
    //Checks sort method — true if alphabetical, false if by date
    private var isAlphabetical = false
    
    
    @IBOutlet weak var allSortType: UISegmentedControl!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllBooksTableViewCell", for: indexPath) as? AllBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of AllBookTableViewCell")
        }
        cell.book = bookManager.allBooks[indexPath.row]
        
        // Configure the cell...

        return cell
    }
    
    // Reload the data of table to make it updated with changes in books (if any).
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // Select a book to move to its details page.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "AllBookToBookDetailsSegue", sender: self)
    }
    
    // Prepare for the BookDetailView before perform the segue to it.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AllBookToBookDetailsSegue"?:
            guard let destination = segue.destination as? BookDetailsViewController else {
                return
            }
            destination.book = bookManager.allBooks[(tableView.indexPathForSelectedRow?.row)!]
        default:
            return
        }
    }
    
    @IBAction func sortTypeChanged(_ sender: UISegmentedControl) {
        switch allSortType.selectedSegmentIndex
        {
        case 0:
            isAlphabetical = true
            bookManager.allBooks = bookManager.allBooks.sorted(by: {makeAlphabetizableTitle(book: $0) < makeAlphabetizableTitle(book: $1)})
        case 1:
            isAlphabetical = false
        default:
            break
        }
        tableView.reloadData()
    }
    
    //(Kelli) function for ignoring "the" substring and case when alphabetizing
    
    private func makeAlphabetizableTitle(book : Book) -> String{
        
        var alphebetizable = book.title.lowercased()
        
        if alphebetizable.characters.count > 4{
            let index = alphebetizable.index(alphebetizable.startIndex, offsetBy: 4)
            let firstThreeLetters = alphebetizable.substring(to: index)
            if firstThreeLetters == "the "{
                alphebetizable = alphebetizable.substring(from: index)
            }
        }
        return alphebetizable
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
