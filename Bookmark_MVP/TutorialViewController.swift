//
//  TutorialViewController.swift
//  BookIt
//
//  Created by Duc Le on 4/22/17.
//  Copyright © 2017 Team Grant_le_mandel. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTutorial)))
    }
    
    func dismissTutorial() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
