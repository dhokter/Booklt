//
//  BookTableViewController.swift
//  BookIt
//
//  Created by Duc Le on 2/23/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import PureLayout

class ReadingBooksTableViewController: UITableViewController, MGSwipeTableCellDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let userDefaults = UserDefaults.standard
    
    // List of books to be displayed on screen, with value passed by the bookManager
    private var books = [Book]()
    private var searchResults = [Book]()
    private var filterType: FilterType = .chronological
    
    // Elements of the header view
    private let searchController = UISearchController(searchResultsController: nil)
    private let sortFilters = UISegmentedControl(items: ["A-Z", "Recent", "% Complete", "Color"])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        setUpSortFilters()
        createTableHeaderView()
        
        if userDefaults.object(forKey: "isFirstTime") == nil {
            performSegue(withIdentifier: "displayTutorial", sender: self)
            userDefaults.set(true, forKey: "isFirstTime")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func setUpSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles  = ["All", "Title", "Author"]
    }
    
    private func setUpSortFilters() {
        sortFilters.selectedSegmentIndex = 1
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
        
        self.tableView.tableHeaderView = headerView
    }
    
    // The function to reload the data if the view appear again by the BACK button of some other ViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
        if searchController.isActive {
            return searchResults.count
        }
        return books.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ReadingBooksTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReadingBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of BookTableViewCell")
        }
        if searchController.isActive {
            cell.book = searchResults[indexPath.row]
        } else {
            cell.book = books[indexPath.row]
        }
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ReadingToDetails", sender: self)
    }
    
    // Prepare the data before a segue. Divided by cases, each cases using Segue Identifier to perform appropriate action
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "ReadingToDetails"?:
            guard let destination = segue.destination as? BookViewController else {     // Pass the book instance of the cell to the ViewController to display
                return
            }
            if searchController.isActive {
                destination.book = searchResults[(tableView.indexPathForSelectedRow?.row)!]
            } else {
                destination.book = books[(tableView.indexPathForSelectedRow?.row)!]
            }
            destination.displayMode = .details
        case "ReadingToAdd"?:
            guard let destination = segue.destination as? BookViewController else {
                return
            }
            destination.displayMode = .newReading
        default: return
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        let indexPath = self.tableView.indexPath(for: cell)
        let book: Book
        
        if searchController.isActive {
            book = searchResults[(indexPath?.row)!]
        } else {
            book = books[(indexPath?.row)!]
        }
        
        if direction == MGSwipeDirection.leftToRight {
            return [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {(sender: MGSwipeTableCell)->Bool in
                self.confirmDeleteBook(indexPath: indexPath!, book: book)
                return false
            })]
        } else {
            return [MGSwipeButton(title: "Mark as Done", backgroundColor: .green, callback: {(sender: MGSwipeTableCell)->Bool in
                bookManager.markAsCompleted(book: book)
                self.deleteAndUpdateCells(indexPath: indexPath!)
                return false
            })]
        }
    }
    
    
    // The function the for unwind segue from the AddBookView.
    @IBAction func addNewBook(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? BookViewController {
            bookManager.addNewBook(book: sourceViewController.book!, state: "reading")
            books = bookManager.readingBooks
            let newIndexPath = IndexPath(row: books.count-1, section: 0)        // Creates a new cell for the book
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
            
            tableView.reloadData()
        }
    }
    
    //(Kelli) Activated when user switches between "A-Z" and "Date" sort methods
    func sortTypeChanged(_ sender: Any) {
        switch sortFilters.selectedSegmentIndex
        {
        case 0:                             // "A-Z" is selected
            filterType = .alphabetical
        case 1:                             // "Date" is selected
            filterType = .chronological
        case 2:                            // "Progress ↓" is selected
            filterType = .decreasingProgress
        case 3:
            filterType = .color
        default:
            break
        }
        if searchController.isActive {
            searchResults = bookManager.sortBooks(books: searchResults, filter: filterType)
        } else {
            books = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        }
        tableView.reloadData()
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    private func deleteAndUpdateCells(indexPath: IndexPath) {
        books = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        // Check add update the searchResult here to fix the bug that searchResult not updated  if called from outside function,, maybe due to different threads perform the delete and search at the same time.
        if self.searchController.isActive {
            let book = searchResults[indexPath.row]
            self.searchResults = self.searchResults.filter({$0 !== book})
        }
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
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action: UIAlertAction) in
            bookManager.delete(book: book)
            self.deleteAndUpdateCells(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            let cell = self.tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
            cell.hideSwipe(animated: true)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // SEARCHBAR CONFIGURATION
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        search(searchText: searchBar.text!, scope: scope)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![selectedScope]
        search(searchText: searchBar.text!, scope: scope)
    }
    
    private func search(searchText: String, scope: String = "All") {
        searchResults = bookManager.search(searchText: searchText, books: books, scope: scope)
        tableView.reloadData()
    }
}
