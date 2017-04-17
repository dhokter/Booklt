//
//  WishListBooksViewController.swift
//  Bookmark_MVP
//
//  Created by Spencer Grant on 3/28/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RealmSwift
import PureLayout

class WishListBooksTableViewController: UITableViewController, MGSwipeTableCellDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let realm = try! Realm()
    
    private var books = [Book]()
    private var searchResults = [Book]()
    private var filterType: FilterType = .alphabetical
    
    // Elements of the header view
    private let searchController = UISearchController(searchResultsController: nil)
    private let sortFilters = UISegmentedControl(items: ["A-Z", "Recent"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        setUpSortFilters()
        createTableHeader()
        
        
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
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Author"]
    }
    
    private func setUpSortFilters() {
        sortFilters.selectedSegmentIndex = 0
        sortFilters.addTarget(self, action: #selector(sortTypeChanged(_:)), for: .valueChanged)
    }
    
    private func createTableHeader() {
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
    
    // Reload the data of table to make it updated with changes in books (if any).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        books = bookManager.sortBooks(books: bookManager.wishListBooks, filter: filterType)
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
        if searchController.isActive {
            return searchResults.count
        } else {
            return books.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WishListBooksTableViewCell", for: indexPath) as? WishListBooksTableViewCell else {
            fatalError("The dequeued cell is not an instance of WishListBookTableViewCell")
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
        self.performSegue(withIdentifier: "WishListToDetails", sender: self)
    }
        
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return true
    }
    
    @IBAction func addNewBook(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddBookViewController {
            bookManager.addNewBook(book: sourceViewController.book!, state: .wishList)
            books = bookManager.wishListBooks
            let newIndexPath = IndexPath(row: books.count-1, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
            
            tableView.reloadData()
        }
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
            return [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {(sender: MGSwipeTableCell) -> Bool in
                self.confirmDeleteBook(indexPath: indexPath!, book: book)
                return false
            })]
        } else {
            return [MGSwipeButton(title: "Mark as Reading", backgroundColor: .green, callback: {(sender: MGSwipeTableCell) -> Bool in
                self.beginReading(indexPath: indexPath!, book: book)
                return false
            })]
        }
    }
    
    private func deleteAndUpdateCells(indexPath: IndexPath) {
        books = bookManager.sortBooks(books: bookManager.wishListBooks, filter: filterType)
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
    
    /////IN PROGRESS
    private func beginReading(indexPath: IndexPath, book: Book) {
        let alert = UIAlertController(title: "More Info Required", message: "Please provide the following information before you begin reading", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {(action: UIAlertAction) in
            try! self.realm.write {
                book.currentPage = Int((alert.textFields?[0].text)!) ?? 0
                book.totalPages = Int((alert.textFields?[1].text)!) ?? 0
            }
            bookManager.markAsReading(book: book)
            self.deleteAndUpdateCells(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            let cell = self.tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
            cell.hideSwipe(animated: true)
        }))
        
        alert.addTextField { (currentPage) in
            currentPage.placeholder = "Current page"
            currentPage.keyboardType = .numberPad
        }
        
        alert.addTextField { (totalPages) in
            totalPages.placeholder = "Total number of pages"
            totalPages.keyboardType = .numberPad
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sortTypeChanged(_ sender: Any) {
        switch sortFilters.selectedSegmentIndex
        {
        case 0:                             // "A-Z" is selected
            filterType = .alphabetical
        case 1:                             // "Date" is selected
            filterType = .chronological
        case 2:                             // "Progress ↑" is selected
            filterType = .increasingProgress
        case 3:                             // "Progress ↓" is selected
            filterType = .decreasingProgress
        default:
            break
        }
        if searchController.isActive {
            searchResults = bookManager.sortBooks(books: searchResults, filter: filterType)
        } else {
            books = bookManager.sortBooks(books: bookManager.wishListBooks, filter: filterType)
        }
        tableView.reloadData()
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
    
    func search(searchText: String, scope: String = "All") {
        switch scope {
        case "All":
            searchResults = books.filter({($0.title.lowercased().contains(searchText.lowercased()) || $0.author.lowercased().contains(searchText.lowercased()))})
        case "Title":
            searchResults = books.filter({($0.title.lowercased().contains(searchText.lowercased()))})
        case "Author":
            searchResults = books.filter({($0.author.lowercased().contains(searchText.lowercased()))})
        default:
            return
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "WishListToAdd"?:
            guard let destination = segue.destination as? AddBookViewController else {
                return
            }
            destination.displayMode = .newWishList
        case "WishListToDetails"?:
            guard let destination = segue.destination as? AddBookViewController else {
                return
            }
            if searchController.isActive {
                destination.book = searchResults[(self.tableView.indexPathForSelectedRow?.row)!]
            } else {
                destination.book = books[(self.tableView.indexPathForSelectedRow?.row)!]
            }
            destination.displayMode = .detailsWishList
        default:
            return
        }
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
