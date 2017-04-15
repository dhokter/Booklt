//
//  AllBooksTableViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/7/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import PureLayout

class CompletedBooksTableViewController: UITableViewController, MGSwipeTableCellDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    private var books = [Book]()
    private var filterType: FilterType = .chronological
    
    // Search controller using the current tableView to display the result
    private let searchController = UISearchController(searchResultsController: nil)
    private let sortFilters = UISegmentedControl(items: ["A-Z", "Recent"])
    
    private var searchResults = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSortFilters()
        setUpSearchBar()
        createTableHeaderView()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func setUpSearchBar() {
        // Set up the search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        // Set to make the view state the same when switching between tab while searching.
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Author"]
    }
    
    private func setUpSortFilters() {
        sortFilters.selectedSegmentIndex = 0
        sortFilters.addTarget(self, action: #selector(sortTypeChanged(_:)), for: .valueChanged)
    }
    
    private func createTableHeaderView() {
        let headerView = UIView()
        headerView.bounds = searchController.searchBar.bounds
        headerView.bounds.size.height += sortFilters.bounds.size.height
        
        headerView.addSubview(searchController.searchBar)
        headerView.addSubview(sortFilters)
        
        sortFilters.autoPinEdge(.bottom, to: .bottom, of: headerView)
        sortFilters.autoPinEdge(.leading, to: .leading, of: headerView)
        sortFilters.autoPinEdge(.trailing, to: .trailing, of: headerView)
        
        tableView.tableHeaderView = headerView
    }
    
    // Reload the data of table to make it updated with changes in books (if any).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        books = bookManager.sortBooks(books: bookManager.finishedBooks, filter: filterType)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchController.isActive = false
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
        if searchController.isActive {
            return searchResults.count
        }
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedBooksTableViewCell", for: indexPath) as? CompletedBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of AllBookTableViewCell")
        }
        if searchController.isActive {
            cell.book = searchResults[indexPath.row]
        } else {
            cell.book = books[indexPath.row]
        }
        cell.delegate = self
        
        return cell
    }
    
    // TODO: Make the searchCOntroller be inactive before perform the segue to prevent an overlap display. --> SOLVED by set definesPresentationContext
    // Select a book to move to its details page.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CompletedToBookDetailsSegue", sender: self)
    }
    
    // TODO: the books list used in this method is also depended on the searchController is active or inactive --> SOLVED
    // Prepare for the BookDetailView before perform the segue to it.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CompletedToBookDetailsSegue"?:
            guard let destination = segue.destination as? AddBookViewController else {
                return
            }
            if searchController.isActive {
                destination.book = searchResults[(tableView.indexPathForSelectedRow?.row)!]
            } else {
                destination.book = books[(tableView.indexPathForSelectedRow?.row)!]
            }
        default:
            return
        }
    }
    
    
    // TODO: This method should consider the books list in the context of searchViewController is active or not ----> SOLVED
    func sortTypeChanged(_ sender: UISegmentedControl) {
        switch sortFilters.selectedSegmentIndex
        {
        case 0:
            filterType = .alphabetical
        case 1:
            filterType = .chronological
        default:
            break
        }
        if searchController.isActive {
            searchResults = bookManager.sortBooks(books: searchResults, filter: filterType)
        }
        books = bookManager.sortBooks(books: bookManager.finishedBooks, filter: filterType)
        tableView.reloadData()
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    // TODO: The books list used inside this function needs to be depended on searchController is active or not ---> SOLVED
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        let indexPath = self.tableView.indexPath(for: cell)
        let book: Book
        
        if searchController.isActive {
            book = searchResults[(indexPath?.row)!]
        } else {
            book = books[(indexPath?.row)!]
        }
        
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
    
    // TODO: The deletion will need to consider update both books lists variables if the searchController is active --> SOLVED in method above
    private func deleteAndUpdateCells(indexPath: IndexPath) {
        books = bookManager.sortBooks(books: bookManager.finishedBooks, filter: filterType)
        // Check add update the searchResult here to fix the bug that searchResult not updated  if called from outside function,, maybe due to different threads perform the delete and search at the same time.
        if self.searchController.isActive {
            let book = searchResults[indexPath.row]
            self.searchResults = self.searchResults.filter({$0 !== book})
        }
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
    
    // SEARCHBAR CONFIGURATION AND METHODS
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        search(searchText: searchBar.text!, scope: scope)
    }
    
    // Making the search react instantaneously if the user keep the text in the searchbar and switch between different scope
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![selectedScope]
        search(searchText: searchBar.text!, scope: scope)
    }

    private func search(searchText: String, scope: String = "All") {
        switch scope {
        case "All":
            searchResults = books.filter({($0.title.lowercased().contains(searchText.lowercased())) || $0.author.lowercased().contains(searchText.lowercased())})
        case "Title":
            searchResults = books.filter({($0.title.lowercased().contains(searchText.lowercased()))})
        case "Author":
            searchResults = books.filter({($0.author.lowercased().contains(searchText.lowercased()))})
        default:
            return
        }
        
        tableView.reloadData()
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
