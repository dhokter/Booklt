//
//  SearchViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/21/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pageCountLabel: UILabel!
    
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
                let json = JSON(data: data!)
                print(json["items"][0]["volumeInfo"]["authors"])
                let authors = json["items"][0]["volumeInfo"]["authors"].arrayValue.map({$0.stringValue})
                let pages = json["items"][0]["volumeInfo"]["pageCount"].stringValue
                // Make the codes to run in the main thread (thread 1)
                DispatchQueue.main.async {
                    self.authorLabel.text = authors.joined(separator: ", ")
                    self.pageCountLabel.text = pages
                }
            }
        })
        task.resume()

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
