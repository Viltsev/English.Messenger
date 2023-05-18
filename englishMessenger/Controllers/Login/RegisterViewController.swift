//
//  RegisterViewController.swift
//  englishMessenger
//
//  Created by Данила on 15.02.2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    // MARK: UI-элементы
    
    //  spinner, который отображается при ожидании регистрации
    private let spinner = JGProgressHUD(style: .dark)
    
    // title Registration
    private let titleLabel: UILabel = {
       let title = UILabel()
        title.text = "Registration"
        title.font = UIFont(name: "Simpleoak", size: 60)
        title.textColor = .systemPurple
        title.textAlignment = .center
        return title
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // scroll view
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
        field.layer.borderColor = UIColor.systemPurple.cgColor
        field.placeholder = "Email Adress..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemPurple
        field.textColor = .white
        field.font = UIFont(name: "Optima", size: 20)
        
        return field
    }()
    
    // firstNameField
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemPurple.cgColor
        field.placeholder = "First Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemPurple
        field.textColor = .white
        field.font = UIFont(name: "Optima", size: 20)
        
        return field
    }()
    
    // lastNameField
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemPurple.cgColor
        field.placeholder = "Last Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemPurple
        field.textColor = .white
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
        field.layer.borderColor = UIColor.systemPurple.cgColor
        field.placeholder = "Password..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemPurple
        field.textColor = .white
        field.font = UIFont(name: "Optima", size: 20)
        field.isSecureTextEntry = true
        
        return field
    }()
    
    // registerButton
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemPurple
        
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "darkgreen")
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.tintColor = .systemPurple
        
        // добавление функции registerButtonTapped к кнопке регистрации
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // add subviews
        // view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        
        imageView.addGestureRecognizer(gesture)
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
        
        firstNameField.frame = CGRect(x: 30,
                                      y: titleLabel.bottom + 10,
                                      width: scrollView.width - 60,
                                      height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                     y: firstNameField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        
    }
    
    
    @objc private func didTapChangeProfilePicture() {
        print("Changed")
    }
    
    // MARK: функция регистрации
    @objc private func registerButtonTapped() {
        
        // скрываем клавиатуры из emailField, passwordField,
        // firstNameField и lastNameField
        // с помощью метода resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        // проверка, ввели ли данные в email и password
        // поля emailField и passwordField должны быть заполнены, а также пароль должен содержать более 6 символов
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
                  alertUserLoginError()
                  return
              }
        
        // запуск спиннера загрузки
        spinner.show(in: view)
        
        // Firebase login
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            
            // Конструкция guard let strongSelf = self else { return } используется для обеспечения безопасности работы с опциональными значениями в замыканиях или асинхронных операциях, особенно в контексте захвата (capture) self внутри замыкания.
            // Когда замыкание захватывает self, это может создать цикл сильных ссылок (strong reference cycle) между замыканием и экземпляром класса. Цикл сильных ссылок может привести к утечке памяти, когда экземпляр класса не будет освобождаться из памяти, даже когда он больше не нужен.
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                // пользователь уже создан
                strongSelf.alertUserLoginError(message: "User already has been created!")
                return
            }
            
            // вызов функции создания нового пользователя
            FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                                password: password,
                                                completion: { authResult, error in
                guard authResult != nil, error == nil else {
//                    strongSelf.alertUserLoginError(message: "User already has been created!")
                    print("Error creating user")
                    return
                }
                
                // создаем нового пользователя по структуре AppUser
                let chatUser = AppUser(firstName: firstName,
                                       lastName: lastName,
                                       emailAddress: email)
                
//                DatabaseManager.shared.insertNewUser(with: chatUser, completion: { success in
//                    if success {
//                        // upload image
//
//                    }
//                })
                
                // Экран логина дисмисится, возвращаемся в initial view controller
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })

            
        })
        
    }
    
    func alertUserLoginError(message: String = "Please, enter all info to create new account") {
        let alert = UIAlertController(title: "Ooops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
        

}

// MARK: extension для RegisterViewController
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // функция раскрытия клавиатура при нажатии на emailField
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        // или passwordField
        else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
}
