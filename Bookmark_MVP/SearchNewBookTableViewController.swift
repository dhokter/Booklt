//
//  SearchNewBookTableViewController.swift
//  BookIt
//
//  Created by Duc Le on 5/16/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import SwiftyJSON

struct BookFromAPI {
    var title: String
    var authors: [String]
    var totalPages: Int
    var cover: UIImage
}

class SearchNewBookTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var books = [BookFromAPI]()

    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func createSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Author"]
        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchNewBookTableViewCell", for: indexPath) as? SearchNewBookTableViewCell else {
            fatalError("The dequeued cell is not an instance of SearchNewBookTableViewCell")
        }
        
        // Configure the cell...
        cell.book = books[indexPath.row]
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        search(text: searchBar.text!, scope: scope)
    }
    
    private func search(text: String, scope: String = "All") {
        books = []
        search(text: text, scope: scope)
    }
    
    private func searchAPI(text: String, scope: String = "All") {
        let urlRequest = URLRequest(url: createSearchURL(text: text, scope: scope))
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            if error != nil {
                return
            } else {
                let jsonData = JSON(data: data!)["items"].arrayValue
                if jsonData != [] {
                    for book in jsonData {
                        let title = book["volumeInfo"]["title"].stringValue
                        let authors = book["volumeInfo"]["authors"].arrayValue.map({$0.stringValue})
                        let totalPages = book["volumeInfo"]["pageCount"].intValue
                        
                        let coverImage: UIImage
                        if let coverURL = book["volumeInfo"]["imageLinks"]["thumbnail"].string {
                            let imageData = try? Data(contentsOf: URL(string: coverURL)!)
                            coverImage = UIImage(data: imageData!)!
                        } else {
                            coverImage = #imageLiteral(resourceName: "default")
                        }
                        self.books.append(BookFromAPI(title: title, authors: authors, totalPages: totalPages, cover: coverImage))
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        task.resume()
    }
    
    private func createSearchURL(text: String, scope: String = "All") -> URL {
        var googleSearchURL = "https://www.googleapis.com/books/v1/volumes?q="
        switch scope {
        case "Author":
            googleSearchURL.append("inauthor:\(text)")
        case "Title":
            googleSearchURL.append("intitle:\(text)")
        default:
            googleSearchURL.append("\(text)")
        }
        
        googleSearchURL = googleSearchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: googleSearchURL) else {
            return URL(string: "https://www.googleapis.com/books/v1/volumes?q=")!
        }
        
        return url
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
