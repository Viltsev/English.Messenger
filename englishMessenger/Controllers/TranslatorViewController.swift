//
//  TranslatorViewController.swift
//  englishMessenger
//
//  Created by Данила on 17.05.2023.
//

import UIKit
import Alamofire
import FirebaseFirestore

// MARK: структуры для данных из JSON
struct TranslateData: Codable {
    let data: MainData
}

struct MainData: Codable {
    let translatedText: String
}

class TranslatorViewController: UIViewController {
    
    let database = Firestore.firestore()
    
    var amountOfTranslations = 0
    
    // MARK: Network
    let session = URLSession.shared
    let decoder = JSONDecoder()
    
    
    // MARK: UI
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    private let buttonSend: UIButton = {
        let button = UIButton()
        button.setTitle("Перевести", for: .normal)
        button.backgroundColor = UIColor(named: "darkPurple")
        
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        button.titleLabel?.textColor = UIColor(named: "cellColor")
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let buttonSave: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить в словарь", for: .normal)
        button.backgroundColor = UIColor(named: "darkPurple")

        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        button.titleLabel?.textColor = UIColor(named: "cellColor")
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let textFieldSource: UITextView = {
        let field = UITextView()
        field.font = UIFont.systemFont(ofSize: 18)
        field.textColor = UIColor(named: "darkPurple")
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor(named: "darkPurple")?.cgColor
        field.sizeToFit()
        return field
    }()
    
    private let textFieldTarget: UITextView = {
        let field = UITextView()
        field.font = UIFont.systemFont(ofSize: 18)
        field.textColor = UIColor(named: "darkPurple")
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor(named: "profileBackground")?.cgColor
        field.isEditable = false
        field.sizeToFit()
        return field
    }()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "cellColor")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "cellColor")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
//        textFieldSource.delegate = self
//        textFieldTarget.delegate = self
        
        let button = UIBarButtonItem(title: "Назад", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = UIColor(named: "darkPurple")
        navigationItem.leftBarButtonItem = button

        
        buttonSend.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        buttonSave.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // placement of UI-elements
        view.addSubview(textFieldSource)
        view.addSubview(textFieldTarget)
        view.addSubview(buttonSend)
        view.addSubview(buttonSave)
        view.addSubview(tableView)
        
        getNumberOfTranslation { result in
            self.amountOfTranslations = result
            self.tableView.reloadData()
        }
    }
    
    // MARK: UI-positions
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let messageFieldWidth = view.frame.size.width - 20
        let viewMaxY = view.frame.height
        let messageFieldX = view.frame.size.width/2 - messageFieldWidth / 2
        textFieldSource.frame = CGRect(x: messageFieldX,
                                       y: view.safeAreaInsets.top + 10,
                                       width: messageFieldWidth,
                                       height: 70)
        textFieldTarget.frame = CGRect(x: messageFieldX,
                                       y: textFieldSource.bottom + 20,
                                       width: messageFieldWidth,
                                       height: 70)
        buttonSend.frame = CGRect(x: messageFieldX, y: textFieldTarget.bottom + 20, width: messageFieldWidth, height: 70)
        buttonSave.frame = CGRect(x: messageFieldX, y: buttonSend.bottom + 20, width: messageFieldWidth, height: 70)
        tableView.frame = CGRect(x: messageFieldX, y: buttonSave.bottom + 20, width: messageFieldWidth, height: viewMaxY - buttonSave.bottom - 100)
    }
    
    // MARK: Back to previous view
    @objc private func buttonTapped() {
       dismiss(animated: true, completion: nil)
    }
    
    // MARK: функция запроса для перевода текста
    @objc private func sendButtonTapped() {
        // создание очереди translatorQueue с уровнем приоритета utility
        let translatorQueue = DispatchQueue.global(qos: .utility)
        // вызов функции obtainData асинхронно в созданной очереди
        translatorQueue.async {
            self.obtainData()
        }
        getNumberOfTranslation { result in
            self.amountOfTranslations = result
        }
    }
    
    // MARK: функция сохранения слова/текста в словарь
    @objc private func saveButtonTapped() {
        if textFieldTarget.text != "" {
            guard let currentText = textFieldSource.text, let currentTranslation = textFieldTarget.text else {
                return
            }
            
            
            // получаем из UserDefaults почту текущего пользователя
            let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
            // записываем данные для конкретного пользователя
            let docRef = database.document("userDictionary/\(currentEmail)")
            docRef.setData(["translation_\(amountOfTranslations+1)": ["english": currentTranslation, "russian": currentText]], merge: true)
            docRef.setData(["amount": amountOfTranslations + 1], merge: true)
            getNumberOfTranslation { result in
                self.amountOfTranslations = result
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // MARK: функция получения количества слов в словаре
    func getNumberOfTranslation(completion: @escaping (Int) -> Void) {
        let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
        let docRef = database.document("userDictionary/\(currentEmail)")
        
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(0) // Возвращаем значение по умолчанию или обрабатываем ошибку
                return
            }
            
            guard let number = data["amount"] as? Int else {
                completion(0) // Возвращаем значение по умолчанию или обрабатываем ошибку
                return
            }
            
            completion(number) // Возвращаем полученное значение
        }
    }
    
    // Вызывается при нажатии кнопки Return на клавиатуре
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder() // Убрать клавиатуру
        return true
    }

    // Вызывается при касании вне текстового поля
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // Убрать клавиатуру
    }

    
//    func getNumberOfTranslation() -> Int {
//        let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
//        // получаем доступ к документу в Firestore по заданному пути
//        let docRef = database.document("userDictionary/\(currentEmail)")
//        var amount = 0
//        // с помощью addSnapshotListener считываем данные из БД
//        docRef.addSnapshotListener { snapshot, error in
//            guard let data = snapshot?.data(), error == nil else {
//                return
//            }
//
//            // получаем из data вопрос с переданным в функцию номером вопроса
//            guard let number = data["amount"] as? Int else {
//                return
//            }
//            amount = number
//
//        }
//
//        return amount
//    }
    
}

extension TranslatorViewController {
    // MARK: Network Part
    // MARK: функция перевода введенного текста
    func obtainData() {
        // введенный текст для перевода
        let text = textFieldSource.text
        
        // хэдеры
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "X-RapidAPI-Key": "cd02c58415mshb53743187d9ff8ap1c314fjsn07806753884e",
            "X-RapidAPI-Host": "text-translator2.p.rapidapi.com"
        ]
        
        // параметры для осуществления запроса на сервер TextTranslator
        let postData = NSMutableData(data: "source_language=ru".data(using: String.Encoding.utf8)!)
        postData.append("&target_language=en".data(using: String.Encoding.utf8)!)
        postData.append("&text=\(text!)".data(using: String.Encoding.utf8)!)
        
        // переменная, с помощью которой будет осуществляться запрос
        let request = NSMutableURLRequest(url: NSURL(string: "https://text-translator2.p.rapidapi.com/translate")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        
        // получение данных
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
            
            guard let strongSelf = self else { return }
            
            if error == nil, let parseData = data {
                let responseData = try? strongSelf.decoder.decode(TranslateData.self, from: parseData)
                let translate = responseData?.data.translatedText
                // вывод переводимого текста асинхронно в главном потоке
                DispatchQueue.main.async {
                    strongSelf.textFieldTarget.text = translate
                }
            }
            else {
                print("error!!")
            }
            
        })

        dataTask.resume()
    }

}

extension TranslatorViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: TableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // Указываем количество секций равным количеству ячеек
       return amountOfTranslations
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(named: "profileBackground")
        cell.layer.cornerRadius = 20 // Радиус закругления ячейки
        cell.textLabel?.textColor = UIColor(named: "darkPurple")
        
        let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
        // получаем доступ к документу в Firestore по заданному пути
        let docRef = database.document("userDictionary/\(currentEmail)")

        // с помощью addSnapshotListener считываем данные из БД
        docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }

            // получаем из data вопрос с переданным в функцию номером вопроса
            guard let dataNew = data["translation_\(indexPath.section+1)"] as? [String: Any] else {
                    return
            }

            // записываем данные полученные в text в соответствующие элементы для дальнейшего отображения
            DispatchQueue.main.async {
                //cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                cell.textLabel?.text = dataNew["russian"] as? String
                cell.detailTextLabel?.text = dataNew["english"] as? String
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0) // Задайте нужную высоту отступа

        return headerView
    }
    
    
    // высота ячеек таблицы
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
