//
//  SearchViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/21/17.
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

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:       UITableView!
    @IBOutlet weak var titleTextField:  UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    // List of books found from the API to display
    var searchResults: [BookFromAPI] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchTouched(_ sender: UIButton) {
        if let title = titleTextField.text {
            if let author = authorTextField.text {
                searchForBook(title: title, author: author)
            } else {
                searchForBook(title: title)
            }
        }
    }
    
    private func searchForBook(title: String, author: String = "") {
        var googleBookSearch = ""
        if author != "" {
            googleBookSearch = "https://www.googleapis.com/books/v1/volumes?q=\(title.replacingOccurrences(of: " ", with: "%20"))+inauthor:\(author.replacingOccurrences(of: " ", with: "%20").capitalized)"
        } else {
            googleBookSearch = "https://www.googleapis.com/books/v1/volumes?q=\(title.replacingOccurrences(of: " ", with: "%20"))"
        }
        
        print("--------------> \(googleBookSearch)")
        // TODO: App crashes if entered special characters from other languages, such as Vietnamese
        googleBookSearch = googleBookSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
        let url = URL(string: googleBookSearch)!
        print("----------> URL is: \(url)")
        let request = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if error != nil {
                self.searchFailed()
                return
            } else {
                self.searchResults = []
                let json = JSON(data: data!)["items"].arrayValue
                if json != [] {
                    for book in json {
                        // TODO: Some books does not have images, this will crash the app ---> SOLVED, untested fully
                        var cover: UIImage
                        if let urlString = book["volumeInfo"]["imageLinks"]["thumbnail"].string {
                            let dataImage = try? Data(contentsOf: URL(string: urlString)!)
                            cover = UIImage(data: dataImage!)!
                        } else {
                            cover = #imageLiteral(resourceName: "default")
                        }
                        self.searchResults.append(BookFromAPI(title: book["volumeInfo"]["title"].stringValue, authors: book["volumeInfo"]["authors"].arrayValue.map({$0.stringValue}), totalPages: book["volumeInfo"]["pageCount"].intValue, cover: cover))
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    self.searchFailed()
                }
            }
        })
        task.resume()
    }
    
    private func searchFailed() {
        let alertNoBook = UIAlertController(title: "Search failed", message: "There is no book in the database matched your given information, or you are not connected to internet.\nPlease make a new search.", preferredStyle: .alert)
        
        alertNoBook.addAction(UIAlertAction(title: "New search", style: .default, handler: {(UIAlertAction) -> Void in
            return
        }))
        
        // Call the alert in the main thread, since it is UI
        DispatchQueue.main.async {
            self.searchResults = []
            self.tableView.reloadData()
            self.present(alertNoBook, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchBookTableViewCell else {
            fatalError("Cannot filled the cell")
        }
        cell.book = searchResults[indexPath.row]
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let title = titleTextField.text {
            if let author = authorTextField.text {
                searchForBook(title: title, author: author)
            } else {
                searchForBook(title: title)
            }
        }
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
