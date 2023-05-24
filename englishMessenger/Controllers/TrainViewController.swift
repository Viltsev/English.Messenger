//
//  TrainViewController.swift
//  englishMessenger
//
//  Created by Данила on 19.05.2023.
//

import UIKit

class TrainViewController: UIViewController {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pandaTrain")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let buttonContinue: UIButton = {
        let button = UIButton()
        button.setTitle("Продолжить", for: .normal)
        button.backgroundColor = UIColor(named: "darkPurple")
        button.titleLabel?.font = UIFont(name: "Optima", size: 18)
        button.layer.cornerRadius = 15
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "cellColor")
        
        view.addSubview(imageView)
        view.addSubview(buttonContinue)
        
        self.buttonContinue.addTarget(self, action: #selector(buttonStart), for: .touchUpInside)
        
        
        let button = UIBarButtonItem(title: "Назад", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = UIColor(named: "darkPurple")
        navigationItem.leftBarButtonItem = button
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: view.frame.midX - 200, y: view.frame.midY - 250, width: 400, height: 400)
        buttonContinue.frame = CGRect(x: view.frame.size.width / 2 - 150, y: imageView.bottom + 20, width: 300, height: 100)
        
    }
    
    @objc private func buttonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func buttonStart() {
        let vc = DescribeImageViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    

}
