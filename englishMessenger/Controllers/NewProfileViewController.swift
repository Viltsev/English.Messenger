//
//  NewProfileViewController.swift
//  englishMessenger
//
//  Created by Данила on 17.02.2023.
//

import UIKit
import FirebaseAuth

class NewProfileViewController: UIViewController {

    private let titleNewLabel: UILabel = {
        let title = UILabel()
        title.text = "Profile"
        title.font = UIFont(name: "Simpleoak", size: 60)
        title.textColor = .systemPurple
        title.textAlignment = .center
        return title
    }()
    
    
    private let backToStart: UIButton = {
        let button = UIButton()
        button.setTitle("Back to Start", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    private let levelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Determine The Level", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    private let conversationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go To Conversation", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    private let userInterests: UIButton = {
        let button = UIButton()
        button.setTitle("Your Interests", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "darkgreen")
        
        backToStart.addTarget(self, action: #selector(backToStartFunc), for: .touchUpInside)
        conversationButton.addTarget(self, action: #selector(conversationButtonFunc), for: .touchUpInside)
        
        view.addSubview(titleNewLabel)
        view.addSubview(backToStart)
        view.addSubview(levelButton)
        view.addSubview(conversationButton)
        view.addSubview(userInterests)
//        view.addSubview(loginButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleNewLabel.frame = CGRect(x: view.bounds.midX - 125, y: view.bounds.minY + 20, width: 250, height: 150)
        backToStart.frame = CGRect(x: titleNewLabel.frame.minX, y: titleNewLabel.bottom, width: 250, height: 60)
        levelButton.frame = CGRect(x: backToStart.frame.minX, y: backToStart.bottom + 20, width: 250, height: 60)
        conversationButton.frame = CGRect(x: levelButton.frame.minX, y: levelButton.bottom + 20, width: 250, height: 60)
        userInterests.frame = CGRect(x: conversationButton.frame.minX, y: conversationButton.bottom + 20, width: 250, height: 60)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // пока пользователь не зашел в аккаунт
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = StartViewController() // vc экрана логина
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false) // переход на экран логина
            print("change")
        }
    }
    
    @objc private func conversationButtonFunc() {
        let vc = ConversationsViewController()
        navigationController?.pushViewController(vc, animated: true)
//        vc.title = "Chats"
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true)
    }
    
    
    @objc private func backToStartFunc() {
        let vc = StartViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true) // переход на экран логина
    }

}
