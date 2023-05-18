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
    
    // titleNewLabel
    private let titleNewLabel: UILabel = {
       let title = UILabel()
        title.text = "English Messenger"
        title.font = UIFont(name: "Simpleoak", size: 60)
        title.textColor = .systemPurple
        title.textAlignment = .center
        return title
    }()
    
    // loginButton
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    // signInButton
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "darkgreen")
        
        loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(registration), for: .touchUpInside)
        
        view.addSubview(titleNewLabel)
        view.addSubview(signInButton)
        view.addSubview(loginButton)
    }
    

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        titleNewLabel.frame = CGRect(x: view.bounds.midX - 125, y: view.bounds.midY - 75, width: 250, height: 150)
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
