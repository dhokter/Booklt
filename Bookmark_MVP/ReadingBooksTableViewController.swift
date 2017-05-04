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
    private var books         = [Book]()
    private var searchResults = [Book]()
    private var displayedBooks: [Book] {
        if searchController.isActive {
            return searchResults
        } else {
            return books
        }
    }
    private var filterType: FilterType = .chronological
    
    // Elements of the header view
    private let searchController = UISearchController(searchResultsController: nil)
    private let sortFilters      = UISegmentedControl(items: ["A-Z", "Recent", "% Complete", "Color"])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the header of the table view
        setUpSearchBar()
        setUpSortFilters()
        createTableHeaderView()
        
        // Display tutorial if this is the first time the user opens the app.
        if userDefaults.object(forKey: "isFirstTime") == nil {
            performSegue(withIdentifier: "displayTutorial", sender: self)
            userDefaults.set(true, forKey: "isFirstTime")
        }
    }
    
    // Creates the searchBar for the table header
    private func setUpSearchBar() {
        searchController.searchResultsUpdater             = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext                   = true    // Set to make the view state the same when switching between tabs while searching.
        searchController.searchBar.delegate               = self
        searchController.searchBar.scopeButtonTitles      = ["All", "Title", "Author"]
    }
    
    // Creates the sorting filters for the table header
    private func setUpSortFilters() {
        sortFilters.selectedSegmentIndex = 1
        sortFilters.addTarget(self, action: #selector(sortTypeChanged(_:)), for: .valueChanged)
    }
    
    // Combine searchBar and sorting filters to be table headers
    private func createTableHeaderView() {
        let headerView                 = UIView()
        headerView.bounds              = searchController.searchBar.bounds
        headerView.bounds.size.height += sortFilters.bounds.size.height
        
        headerView.addSubview(searchController.searchBar)
        headerView.addSubview(sortFilters)
        
        sortFilters.autoPinEdge(.bottom, to: .bottom, of: headerView)
        sortFilters.autoPinEdge(.leading, to: .leading, of: headerView)
        sortFilters.autoPinEdge(.trailing, to: .trailing, of: headerView)
        
        self.tableView.tableHeaderView = headerView
    }
    
    // Reload the data if the view appears again by the BACK button of some other ViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        books = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        tableView.reloadData()
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedBooks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ReadingBooksTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ReadingBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of BookTableViewCell")
        }
        cell.book     = displayedBooks[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ReadingToDetails", sender: self)
    }
    
    // Prepare the data to perform the appropriate segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {                                                       // Decide what the destination of the segue should be
        case "ReadingToDetails"?:
            guard let destination = segue.destination as? BookViewController else {     // Pass the book instance of the cell to the ViewController to display
                return
            }
            destination.book        = displayedBooks[(tableView.indexPathForSelectedRow?.row)!]
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
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings:MGSwipeExpansionSettings) -> [UIView]? {
        let indexPath = self.tableView.indexPath(for: cell)
        let book: Book
        
        book = displayedBooks[(indexPath?.row)!]
        
        if direction == MGSwipeDirection.leftToRight {
            let delete = MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {(sender: MGSwipeTableCell)->Bool in
                self.confirmDeleteBook(indexPath: indexPath!, book: book, sender: sender)
                return false
            })
            return [delete]
        } else {
            let changeStatus = MGSwipeButton(title: "Mark as Done", backgroundColor: .green, callback: {(sender: MGSwipeTableCell)->Bool in
                bookManager.markAsCompleted(book: book)
                sender.rightButtons[0].isUserInteractionEnabled = false  // Disables the button immediately after first touch to prevent double tap -> double callback
                self.deleteAndUpdateCells(for: book)
                return false
            })
            return [changeStatus]
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
    
    // Activated when user switches between different sort methods
    func sortTypeChanged(_ sender: Any) {
        switch sortFilters.selectedSegmentIndex
        {
        case 0:                             // "A-Z" is selected
            filterType = .alphabetical
        case 1:                             // "Date" is selected
            filterType = .chronological
        case 2:                             // "% Complete" is selected
            filterType = .decreasingProgress
        case 3:                             // "Color" is selected
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
    
    
    // Override to support conditional editing of the table view. Return false if you do not want the specified item to be editable.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func deleteAndUpdateCells(for book: Book) {
        let indexPath: IndexPath
        guard let index = displayedBooks.index(of: book) else {
            return
        }
        searchResults = bookManager.sortBooks(books: searchResults, filter: filterType)
        books         = bookManager.sortBooks(books: bookManager.readingBooks, filter: filterType)
        
        indexPath     = IndexPath(row: index, section: 0)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    // Present an alert to confirm the deletion of a book and perform tasks accordingly
    private func confirmDeleteBook(indexPath: IndexPath, book: Book, sender: MGSwipeTableCell) {
        let alert = UIAlertController(title: "Please Confirm", message: "Are you sure you want to delete this book?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action: UIAlertAction) in
            bookManager.delete(book: book)
            sender.leftButtons[0].isUserInteractionEnabled = false      // Disables the button immediately after first touch to prevent double tap -> double callback
            self.deleteAndUpdateCells(for: book)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            let cell = self.tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
            cell.hideSwipe(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Update the books being displayed based on what the user has entered into the search field.
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope     = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        search(searchText: searchBar.text!, scope: scope)
    }
    
    // Make the search react instantaneously if the user keeps the text in the searchbar and switches between different scopes
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![selectedScope]
        search(searchText: searchBar.text!, scope: scope)
    }
    
    // Find all the books that are consistent with what the user has entered in the search field.
    private func search(searchText: String, scope: String = "All") {
        searchResults = bookManager.search(searchText: searchText, books: books, scope: scope)
        tableView.reloadData()
    }
}
