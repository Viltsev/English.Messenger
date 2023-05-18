//
//  ViewController.swift
//  englishMessenger
//
//  Created by Данила on 15.02.2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

// MARK: структура диалога пользователя
struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

// MARK: структура последнего сообщения в диалоге пользователя
struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    // спиннер, отображающийся при загрузке диалогов
    private let spinner = JGProgressHUD(style: .dark)
    
    // массив текущих диалогов пользователя типа Conversation
    public var conversations = [Conversation]()
    
    // все существующие пользователи из БД
    private var users = [[String: String]]()
    
    // индекс пользователя
    private var index = Int()
    
    // MARK: UI-элементы
    public let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        
        // navigation bar
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.tintColor = .systemPurple
        
        // right navbar item - переход в окно поиска диалога
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
        // left navbar item - переход в случайный диалог
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play,
                                                           target: self,
                                                           action: #selector(goToRandomDialog))
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        setupTableView()
        fetchConversations()
        startListeningForConversation()
    }
    
    
    // MARK: функция получения текущих диалогов пользователя
    private func startListeningForConversation() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to get convos: \(error)")
            }
            
        })
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ConversationsVC - initial VC
        // при начальном отображении данного VC вызывается функция validateAuth(),
        // которая запускает экран StartViewController, если пользователь еще не залогинился
        validateAuth()
    }
    
    // MARK: функция запуска экрана StartViewController, если пользователя не залогинился
    private func validateAuth() {
        // Если текущего пользователя не существует
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // переход на StartViewController
            let vc = StartViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false) // переход на экран логина
            print("change")
        }
        else {
            conversations.removeAll()
            setupTableView()
            fetchConversations()
            startListeningForConversation()
        }
    }
    
    // MARK: настройка таблицы диалогов
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations(){
        tableView.isHidden = false
    }
    
    // MARK: функция, в которой вызывается функция создания нового диалога
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            // unwrap name and email of the user
            
            self?.createNewConversation(result: result)
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    // MARK: функция перехода в рандомный диалог
    @objc private func goToRandomDialog() {
        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
            switch result {
            // получаем всех существующих пользователей в usersCollection
            case .success(let usersCollection):
                
                // с помощью функции randomElement получаем случайного пользователя из usersCollection
                if let randomUser = usersCollection.randomElement() {
                    
                    // проверяем, есть ли значения name и email для данного user
                    guard let name = randomUser["name"], let email = randomUser["email"] else {
                        return
                    }
                    
                    // из UserDefaults по ключу email получаем почту текущего пользователя
                    let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
                    
                    // с помощью функции safeEmail преобразуем данную почту в "safe" вид
                    let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
                    
                    // если в массиве диалогов уже содержится искомый рандомный диалог
                    if self!.conversations.contains(where: {$0.otherUserEmail == email}) {
                        
                        // находим индекс искомого пользователя по его email
                        for i in 0 ..< (self?.conversations.count)! {
                            if self?.conversations[i].otherUserEmail == email {
                                self?.index = i
                                break
                            }
                        }
                        
                        // достаем по индексу данные об диалоге с искомым пользователем
                        let model = self?.conversations[self!.index]
                        
                        // осуществляем переход в диалог к этому пользователю
                        let vc = ChatViewController(with: model!.otherUserEmail, id: model?.id)
                        vc.title = model?.name
                        vc.navigationItem.largeTitleDisplayMode = .never
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    // иначе начинаем новый диалог
                    else {
                        // если искомый пользователь не есть текущий пользователь
                        if email != safeCurrentEmail {
                            // создаем новый диалог с искомым пользователем
                            let vc = ChatViewController(with: email, id: nil)
                            vc.isNewConversation = true
                            vc.title = name
                            vc.navigationItem.largeTitleDisplayMode = .never
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                        // иначе заново вызываем функцию goToRandomDialog()
                        else {
                            self?.goToRandomDialog()
                        }
                    }
                }
            case .failure(let error):
                print("Failed to get users: \(error)")
            }
        })
        
    }
    
    // MARK: функция создания нового диалога
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: extension для таблицы диалогов
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    // количество ячеек - количество диалогов пользователя
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    // настройка отображения ячейки таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    // функция нажатия на ячейку таблицы - переход в соответствующий диалог
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    // высота ячеек таблицы
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
