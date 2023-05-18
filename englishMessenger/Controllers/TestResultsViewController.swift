//
//  TestResultsViewController.swift
//  englishMessenger
//
//  Created by Данила on 08.04.2023.
//

import UIKit
import Firebase

// MARK: класс TestResultsViewController, подписанный под протокол Level
// для получения кол-ва набранных баллов пользователем
class TestResultsViewController: UIViewController, Level {
    
//    func getUserLevel(level: String) {
//        resultLabel.text = level
//    }
    
    // MARK: основные UI-элементы
    var resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 5
        return label
    }()
    
    private let startTestButton: UIButton = {
        let button = UIButton()
        button.setTitle("Проверить уровень", for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 15
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Test Results"
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        view.addSubview(resultLabel)
        view.addSubview(startTestButton)
        startTestButton.addTarget(self, action: #selector(startTestButtonAction), for: .touchUpInside)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeCurrentUser = DatabaseManager.safeEmail(emailAddress: currentUser)
        print(safeCurrentUser)
        
        DatabaseManager.shared.getLevel(for: "\(safeCurrentUser)") { (level, error) in
            guard let userLevel = level, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.resultLabel.text = userLevel
            }
        }
        
        resultLabel.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 70, width: view.frame.size.width-20, height: 100)
        startTestButton.frame = CGRect(x: view.bounds.midX - 125, y: view.safeAreaInsets.top + 200, width: 250, height: 50)
    }
    
    // MARK: функция получения баллов, набранных за тест
    func sendPoints(amount: Int) {
        // передаем полученное из sendPoints кол-во баллов в checkLevel
        checkLevel(points: amount)
        let vc = DatabaseManager()
        // обновляем в FirebaseDatabase уровень владения пользователя
        vc.updateLevel()
        // отображаем уровень владения языком в resultLabel
        resultLabel.text = UserDefaults.standard.value(forKey: "englishLevel") as? String
    }
    
    // MARK: функция определения уровня владения языком
    func checkLevel(points: Int) {
        switch points {
        case 0...15:
            UserDefaults.standard.set("Begginer", forKey: "englishLevel")
        case 16...29:
            UserDefaults.standard.set("A1", forKey: "englishLevel")
        case 30...40:
            UserDefaults.standard.set("A2", forKey: "englishLevel")
        case 41...54:
            UserDefaults.standard.set("B1", forKey: "englishLevel")
        case 55...59:
            UserDefaults.standard.set("B2", forKey: "englishLevel")
        case 60:
            UserDefaults.standard.set("C1", forKey: "englishLevel")
        default:
            UserDefaults.standard.set("Level is not defined!", forKey: "englishLevel")
        }
    }
    
    @objc private func buttonTapped() {
       dismiss(animated: true, completion: nil)
    }
    
    // MARK: функция начала тестирования
    @objc private func startTestButtonAction() {
        let vc = EnglishTestViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}
