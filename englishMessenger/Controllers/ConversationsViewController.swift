//
//  ViewController.swift
//  englishMessenger
//
//  Created by Данила on 15.02.2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "darkgreen")
        
        /// navigation bar
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.tintColor = .systemPurple
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
//                                                           target: self,
//                                                           action: #selector(backToProfileButton))
//
        
        /// right navigation item
        /// отвечает за переход в окно поиска диалога
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
        /// add subviews
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        setupTableView()
        fetchConversations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// ConversationsVC - initial VC
        /// при начальном отображении данного VC вызывается функция validateAuth(),
        /// которая запускает экран StartViewController, если пользователь еще не залогинился
        validateAuth()
    }
    
    private func validateAuth() {
        /// Если текущего пользователя не существует
        if FirebaseAuth.Auth.auth().currentUser == nil {
            /// переход на StartViewController
            let vc = StartViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false) // переход на экран логина
            print("change")
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private func fetchConversations(){
        tableView.isHidden = false
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            // unwrap name and email of the user
            
            self?.createNewConversation(result: result)
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    @objc private func backToProfileButton() {
//        let vc = NewProfileViewController()
//        let navVC = UINavigationController(rootViewController: vc)
//        present(navVC, animated: true)
//    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello, World"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = ChatViewController(with: "d.viltsev@gmail.com")
        vc.title = "Danila Viltsev"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
