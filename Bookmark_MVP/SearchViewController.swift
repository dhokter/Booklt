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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pageCountLabel: UILabel!
    
    var searchResults: [BookFromAPI] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchTouched(_ sender: UIButton) {
        guard let title = titleTextField.text else {
            return
        }
        let googleBookSearch = "https://www.googleapis.com/books/v1/volumes?q=\(title.replacingOccurrences(of: " ", with: "%20"))"
        print("--------------> \(googleBookSearch)")
        let url = URL(string: googleBookSearch)!
        print("----------> URL is: \(url)")
        let request = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if error != nil {
                print("-----------------> Error occur!!!")
                return
            } else {
//                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//                if let rootDictionary = json as? [String:Any], let items = rootDictionary["items"]  as? [[String:Any]] {
//                    let volumeInfo = items[0]["volumeInfo"] as? [String: Any]
//                    let authors = volumeInfo?["authors"] as? [String]
//                    let page = volumeInfo?["pageCount"] as? Int
//                    //                    let book = items[0]
//                    //                    print("----> Keys: \(book.keys)")
//                    let author = authors?[0]
//                    print("-------> Author: \(author!)")
//                    print("-------> Page count: \(page!)")
//                    self.authorLabel.text = author!
//                    self.pageCountLabel.text = String(page!)
//                }
                //                let json = JSON(data: data!)
                //                let book = json["items"][0] as? [String:Any]
                //                print(book["authors"])
                //                let item = json["items"][0] {
                //                    if let author = item["authors"] {
                //                        self.authorLabel.text = author
                //                    }
                //                }
                print("-----> Data is not null")
                self.searchResults = [];
                let json = JSON(data: data!)["items"].arrayValue
                for book in json {
                    let dataImage = try? Data(contentsOf: URL(string: book["volumeInfo"]["imageLinks"]["thumbnail"].stringValue)!)
                    let cover = UIImage(data: dataImage!)
                    self.searchResults.append(BookFromAPI(title: book["volumeInfo"]["title"].stringValue, authors: book["volumeInfo"]["authors"].arrayValue.map({$0.stringValue}), totalPages: book["volumeInfo"]["pageCount"].intValue, cover: cover!))
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

                
//                print(json["items"][0]["volumeInfo"]["authors"])
//                let authors = json["items"][0]["volumeInfo"]["authors"].arrayValue.map({$0.stringValue})
//                let pages = json["items"][0]["volumeInfo"]["pageCount"].stringValue
//                // Make the codes to run in the main thread (thread 1)
//                DispatchQueue.main.async {
//                    self.authorLabel.text = authors.joined(separator: ", ")
//                    self.pageCountLabel.text = pages
//                }
            }
        })
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchBookTableViewCell else {
            fatalError("Cannot filled the cell")
        }
        cell.book = searchResults[indexPath.row]
        
        return cell;
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
