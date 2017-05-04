//
//  AllBooksTableViewController.swift
//  BookIt
//
//  Created by Duc Le on 3/7/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import PureLayout

class CompletedBooksTableViewController: UITableViewController, MGSwipeTableCellDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    private var filterType: FilterType = .chronological

    // The list of completed books being displayed.
    private var books = [Book]()
    
    // Search controller using the current tableView to display the result
    private let searchController = UISearchController(searchResultsController: nil)
    private let sortFilters = UISegmentedControl(items: ["A-Z", "Recent", "Rating", "Color"])
    
    // The list of books resutled from the user's search
    private var searchResults = [Book]()
    var displayedBooks: [Book] {
        if searchController.isActive {
            return searchResults
        } else {
            return books
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSortFilters()
        setUpSearchBar()
        createTableHeaderView()
    }
    
    private func setUpSearchBar() {
        searchController.searchResultsUpdater             = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext                   = true        // Set to make the view state the same when switching between tab while searching.
        searchController.searchBar.delegate               = self
        searchController.searchBar.scopeButtonTitles      = ["All", "Title", "Author"]
    }
    
    private func setUpSortFilters() {
        sortFilters.selectedSegmentIndex = 1
        sortFilters.addTarget(self, action: #selector(sortTypeChanged(_:)), for: .valueChanged)
    }
    
    private func createTableHeaderView() {
        let headerView                 = UIView()
        headerView.bounds              = searchController.searchBar.bounds
        headerView.bounds.size.height += sortFilters.bounds.size.height
        
        headerView.addSubview(searchController.searchBar)
        headerView.addSubview(sortFilters)
        
        sortFilters.autoPinEdge(.bottom, to: .bottom, of: headerView)
        sortFilters.autoPinEdge(.leading, to: .leading, of: headerView)
        sortFilters.autoPinEdge(.trailing, to: .trailing, of: headerView)
        
        tableView.tableHeaderView = headerView
    }
    
    // Reload the data of the table to make it updated with changes in books (if any).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        books = bookManager.sortBooks(books: bookManager.completedBooks, filter: filterType)
        self.tableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedBooksTableViewCell", for: indexPath) as? CompletedBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of AllBookTableViewCell")
        }
        cell.book     = displayedBooks[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    // Select a book to move to its details page.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CompletedToBookDetailsSegue", sender: self)
    }
    
    // Prepare the BookDetailView before perform the segue to it.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CompletedToBookDetailsSegue"?:
            guard let destination = segue.destination as? BookViewController else {
                return
            }
            destination.book        = displayedBooks[(tableView.indexPathForSelectedRow?.row)!]
            destination.displayMode = .details
        default:
            return
        }
    }
    
    // Sort the books approproately if the sort type has been changed.
    func sortTypeChanged(_ sender: UISegmentedControl) {
        switch sortFilters.selectedSegmentIndex
        {
        case 0:
            filterType = .alphabetical
        case 1:
            filterType = .chronological
        case 2:
            filterType = .rating
        case 3:
            filterType = .color
        default:
            break
        }
        if searchController.isActive {
            searchResults = bookManager.sortBooks(books: searchResults, filter: filterType)
        }
        books = bookManager.sortBooks(books: bookManager.completedBooks, filter: filterType)
        tableView.reloadData()
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        let indexPath = self.tableView.indexPath(for: cell)
        let book: Book
        
        book = displayedBooks[(indexPath?.row)!]
        
        if direction == MGSwipeDirection.leftToRight {
            let delete = MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {(sender: MGSwipeTableCell) -> Bool in
                self.confirmDeleteBook(indexPath: indexPath!, book: book, sender: sender)
                return false
            })
            return [delete]
        } else {
            let changeStatus = MGSwipeButton(title: "Mark as Reading", backgroundColor: .green, callback: {(sender: MGSwipeTableCell) -> Bool in
                bookManager.markAsReading(book: book)
                sender.rightButtons[0].isUserInteractionEnabled = false  // Disables the button immediately after first touch to prevent double tap -> double callback
                self.deleteAndUpdateCells(for: book)
                return false
            })
            return [changeStatus]
        }
    }
    
    private func deleteAndUpdateCells(for book: Book) {
        let indexPath: IndexPath
        guard let index = displayedBooks.index(of: book) else {
            return
        }
        searchResults = bookManager.sortBooks(books: searchResults, filter: filterType)
        books         = bookManager.sortBooks(books: bookManager.completedBooks, filter: filterType)
        
        indexPath = IndexPath(row: index, section: 0)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    private func confirmDeleteBook(indexPath: IndexPath, book: Book, sender: MGSwipeTableCell) {
        let alert = UIAlertController(title: "Please Confirm", message: "Are you sure you want to delete this book?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action: UIAlertAction) in
            bookManager.delete(book: book)
            sender.leftButtons[0].isUserInteractionEnabled = false     // Disables the button immediately after first touch to prevent double tap -> double callback

            self.deleteAndUpdateCells(for: book)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            let cell = self.tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
            cell.hideSwipe(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // Override to support conditional editing of the table view. Return false if you do not want the specified item to be editable.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Update the books being displayed based on what the user has entered into the search field.
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
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
