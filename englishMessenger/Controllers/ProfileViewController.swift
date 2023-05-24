//
//  ProfileViewController.swift
//  englishMessenger
//
//  Created by Данила on 15.02.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
   // @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topViewProfile: UIView!
    
    
    var arrayOfCells: [ProfileCellStruct] = []
    
    @IBOutlet weak var profileNavItem: UINavigationItem!
    @IBOutlet weak var userImage: UIImageView!
    // ячейки таблицы профиля
    let data = ["Выйти", "Определение уровня языка", "Переводчик", "Тренировка", "Порождение потока", "InvokeAll", "Scheduled Executor"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "cellColor")
        
        topViewProfile.layer.cornerRadius = 20
        
        let email = UserDefaults.standard.value(forKey: "email") as! String
        
        print(email)
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        let ref = Database.database().reference()
        
        ref.child("\(safeEmail)").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                let firstName = value["firstName"] as! String
                let lastName = value["lastName"] as! String
                
                self.nameLabel.text = "\(firstName)" + "  " + "\(lastName)"
                // self.surnameLabel.text = lastName
            }
        }
        
        //profileNavItem.titleView?.tintColor = .white
        
        let image = UIImage(named: "myProfileImage")
        userImage.image = image
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        
        
        arrayOfCells = fetchData()
        
        tableView.register(ProfileCell.self,
                           forCellReuseIdentifier: "ProfileCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
        tableView.backgroundColor = UIColor(named: "cellColor")
        tableView.layer.cornerRadius = 20
        tableView.separatorStyle = .none
        
        // Создаем кастомную кнопку
        let customButton = UIButton(type: .custom)
        customButton.setTitle("Выйти", for: .normal)
        customButton.titleLabel?.font = UIFont(name: "Optima", size: 18)
        customButton.titleLabel?.textColor = UIColor(named: "cellColor")
        customButton.addTarget(self, action: #selector(didTapComposeButton), for: .touchUpInside)
        
        // Создаем UIBarButtonItem с кастомной кнопкой
        let customBarButtonItem = UIBarButtonItem(customView: customButton)
        
        // Устанавливаем кастомный UIBarButtonItem как rightBarButtonItem
        navigationItem.rightBarButtonItem = customBarButtonItem
    }
    
    
    @objc private func didTapComposeButton() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "name")
            UserDefaults.standard.removeObject(forKey: "email")
            let vc = StartViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        catch {
            
        }
    }
}

// MARK: extension для ProfileViewController
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
       // Указываем количество секций равным количеству ячеек
       return arrayOfCells.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // Возвращаем 1 для каждой секции
       return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
       let newCell = arrayOfCells[indexPath.section]
       cell.set(cell: newCell)
       
       return cell
    }
   
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 5.0 // Устанавливаем высоту отступа для каждой секции
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.0
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = .clear
//        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0) // Задайте нужную высоту отступа
//
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0) // Задайте нужную высоту отступа

        return headerView
    }
    
    // переход на соответствующий экран при нажатии на соот-ую ячейку таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let vc = TestResultsViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
        if indexPath.section == 1 {
            let vc = TranslatorViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
        if indexPath.section == 2 {
            let vc = TrainViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
        if indexPath.section == 3 {
            let vc = MultithreadingViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
        if indexPath.section == 4 {
            let vc = SecondThreadViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
        if indexPath.section == 5 {
            let vc = ThirdThreadViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
        if indexPath.section == 6 {
            
        }
        
        
    }
}


extension ProfileViewController {
    func fetchData() -> [ProfileCellStruct] {
        let cell1 = ProfileCellStruct(icon: Icons.test, title: "Определение уровня языка")
        let cell2 = ProfileCellStruct(icon: Icons.dictionary, title: "Словарь")
        let cell3 = ProfileCellStruct(icon: Icons.train, title: "Режим Тренировка")
        
        return [cell1, cell2, cell3]
    }
}
