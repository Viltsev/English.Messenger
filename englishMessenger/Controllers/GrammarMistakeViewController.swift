//
//  GrammarMistakeViewController.swift
//  englishMessenger
//
//  Created by Данила on 24.03.2023.
//

import UIKit

class GrammarMistakeViewController: UIViewController {
    
    var grammarMistakeDescription: UILabel = {
        let title = UILabel()
        title.text = "Mistake here"
        title.font = UIFont(name: "Optima", size: 18)
        title.textColor = .systemPurple
        title.textAlignment = .center
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 5
        
        return title
    }()
    
    var grammarReplaceLabel: UILabel = {
        let label = UILabel()
        label.text = "Replace here"
        label.font = UIFont(name: "Optima", size: 18)
        label.textColor = .systemPink
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 5
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(grammarMistakeDescription)
        view.addSubview(grammarReplaceLabel)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height / 5 * 2, width: self.view.bounds.width, height: UIScreen.main.bounds.height / 5 * 3)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        
        grammarMistakeDescription.frame = CGRect(x: view.bounds.midX - 125, y: view.bounds.minY + 20, width: 250, height: 150)
        grammarReplaceLabel.frame = CGRect(x: view.bounds.midX - 125,
                                           y: grammarMistakeDescription.bottom + 20,
                                           width: 250,
                                           height: 50)
    }

}
