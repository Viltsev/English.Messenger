//
//  LoginViewController.swift
//  englishMessenger
//
//  Created by Данила on 15.02.2023.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {

    // MARK: UI-элементы
    
    //  spinner, который отображается при ожидании логина
    private let spinner = JGProgressHUD(style: .dark)
    
    // title Sign In
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Sign In"
        title.font = UIFont(name: "Optima", size: 45)
        title.textColor = UIColor(named: "darkPurple")
        title.textAlignment = .center
        return title
    }()
    
    // logo
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // scrollView
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    // emailField
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(named: "darkPurple")?.cgColor
        field.placeholder = "Email Adress..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor(named: "cellColor")
        field.textColor = UIColor(named: "darkPurple")
        field.font = UIFont(name: "Optima", size: 20)
        
        return field
    }()
    
    // passwordField
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(named: "darkPurple")?.cgColor
        field.placeholder = "Password..."
        
        field.font = UIFont(name: "Optima", size: 20)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor(named: "cellColor")
        field.textColor = UIColor(named: "darkPurple")
        field.isSecureTextEntry = true
        
        return field
    }()
    
    // loginButton
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor(named: "darkPurple")
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "cellColor")
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.tintColor = UIColor(named: "darkPurple")

        // кнопка перехода в окно регистрации
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
//                                                            style: .done,
//                                                            target: self,
//                                                            action: #selector(tapRegister))
        
        // добавление функции loginButtonTapped к кнопке логина
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
        // view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = view.frame.size.width / 6
        
        imageView.frame = CGRect(x: (view.frame.size.width - size) / 2,
                                 y: 80,
                                 width: size,
                                 height: size)
        
        scrollView.frame = view.bounds
        
        titleLabel.frame = CGRect(x: view.bounds.midX - 125, y: view.bounds.minY + 20, width: 250, height: 150)
        
        emailField.frame = CGRect(x: 30,
                                  y: titleLabel.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        
    }
    
    // MARK: функция логина
    @objc private func loginButtonTapped() {
        
        // скрываем клавиатуру из emailField и passwordField
        // с помощью метода resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // проверка, ввели ли данные в email и password
        // поля emailField и passwordField должны быть заполнены, а также пароль должен содержать более 6 символов
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                  alertUserLoginError()
                  return
              }
        
        // запуск спиннера загрузки
        spinner.show(in: view)
        
        // Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email,
                                        password: password,
                                        completion: { [weak self] authResult, error in
            
            // Конструкция guard let strongSelf = self else { return } используется для обеспечения безопасности работы с опциональными значениями в замыканиях или асинхронных операциях, особенно в контексте захвата (capture) self внутри замыкания.
            // Когда замыкание захватывает self, это может создать цикл сильных ссылок (strong reference cycle) между замыканием и экземпляром класса. Цикл сильных ссылок может привести к утечке памяти, когда экземпляр класса не будет освобождаться из памяти, даже когда он больше не нужен.
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                strongSelf.alertUserLoginError(message: "Data entered incorrectly")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            
            // получение данных для пользователя
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["firstName"] as? String,
                          let lastName = userData["lastName"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
                
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            // переход в окно диалогов пользователя
            let vc = ConversationsViewController()
            vc.viewDidLoad()
            
//            strongSelf.succesfullLogin()
            print("Logged in User: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError(message: String = "Please, enter all info to log in") {
        let alert = UIAlertController(title: "Ooops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    // функция перехода на экран регистрации
    @objc private func tapRegister() {
        let vc = RegisterViewController()
        vc.title = "Registration"
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func succesfullLogin() {
//        let vc = ConversationsViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true) // переход на экран логина
//    }

}

// MARK: extension для LoginViewController
extension LoginViewController: UITextFieldDelegate {
    // функция раскрытия клавиатура при нажатии на emailField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        // или passwordField
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}
