//
//  SearchViewController.swift
//  Bookmark_MVP
//
//  Created by Duc Le on 3/21/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

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
        let title = titleTextField.text;
        let googleBookSearch = "https://www.googleapis.com/books/v1/volumes?q=\(title)";
        let url = URL(string: googleBookSearch)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if error == nil {
                return
            } else if data != nil {
                
            }
        
        })
        
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
