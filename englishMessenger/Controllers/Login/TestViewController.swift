//
//  TestViewController.swift
//  englishMessenger
//
//  Created by Данила on 16.02.2023.
//

import UIKit
import FirebaseAuth
class TestViewController: UIViewController {

    // current user
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test"
        view.backgroundColor = .orange
    }
    

}
