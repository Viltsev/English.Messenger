//
//  StartViewController.swift
//  englishMessenger
//
//  Created by Данила on 17.02.2023.
//

import UIKit
import FirebaseAuth


class StartViewController: UIViewController {

    // MARK: UI-элементы
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pandaStart")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // titleNewLabel
    private let titleNewLabel: UILabel = {
       let title = UILabel()
        title.text = "English Messenger"
        title.font = UIFont(name: "Optima", size: 30)
        title.textColor = UIColor(named: "darkPurple")
        title.textAlignment = .center
        return title
    }()
    
    // loginButton
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = UIColor(named: "darkPurple")
        button.setTitleColor(UIColor(named: "cellColor"), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    // signInButton
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = UIColor(named: "darkPurple")
        button.setTitleColor(UIColor(named: "cellColor"), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "cellColor")
        
        loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(registration), for: .touchUpInside)
        
        view.addSubview(titleNewLabel)
        view.addSubview(signInButton)
        view.addSubview(loginButton)
        view.addSubview(imageView)
    }
    

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: view.frame.midX - 150, y: view.frame.minY + 100, width: 300, height: 300)
        titleNewLabel.frame = CGRect(x: view.bounds.midX - 125, y: imageView.bottom + 20, width: 250, height: 150)
        signInButton.frame = CGRect(x: titleNewLabel.frame.minX, y: titleNewLabel.bottom, width: 250, height: 60)
        loginButton.frame = CGRect(x: signInButton.frame.minX, y: signInButton.bottom + 20, width: 250, height: 60)
    }
    
    // MARK: функция перехода в окно регистрации
    @objc private func registration() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: функция перехода в окно логина
    @objc private func signIn() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
