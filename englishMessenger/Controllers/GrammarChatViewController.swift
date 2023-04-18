//
//  GrammarChatViewController.swift
//  englishMessenger
//
//  Created by Данила on 13.04.2023.
//

import UIKit
import Alamofire

class GrammarChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // словарь для хранения сообщений о грамматических ошибках
    var grammarMistakeMessages: [Int: String] = [-1: ""]
    // словарь для хранения сообщений о том, как можно исправить грамматическую ошибку
    var grammarMistakeReplacements: [Int: String] = [-1: ""]
    // tableView
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    // массив грамматических ошибок
    var mistakesArray: [String] = {
        let item = [String]()
        return item
    }()
    
    // MARK: основные UI-элементы
    // TextView с ошибками
    private let fieldWrong: UITextView = {
        let field = UITextView()
        field.text = "message here"
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor.systemPink.cgColor
        field.sizeToFit()
        return field
    }()
    // TextView с исправленными ошибками
    private let fieldRight: UITextView = {
        let field = UITextView()
        field.text = "right message"
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor.green.cgColor
        field.sizeToFit()
        return field
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grammar Mistakes"
        view.backgroundColor = .white
        
        // добавление UI-элементов на экран
        view.addSubview(fieldWrong)
        view.addSubview(fieldRight)
        view.addSubview(tableView)
        
        // кнопка для возврата на предыдущий экран
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        fieldWrong.dataDetectorTypes = UIDataDetectorTypes.all
        fieldWrong.isEditable = false
        
        // передаем в текстовые поля сообщение пользователя
        fieldWrong.text = UserDefaults.standard.value(forKey: "userMessage") as? String
        fieldRight.text = UserDefaults.standard.value(forKey: "userMessage") as? String
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // вызов функции проверки на грамматические ошибки
        checkGrammar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let messageFieldWidth = view.frame.size.width - 20
        let messageFieldX = view.frame.size.width/2 - messageFieldWidth / 2
        fieldWrong.frame = CGRect(x: messageFieldX,
                             y: view.safeAreaInsets.top + 10,
                             width: messageFieldWidth,
                             height: 200)
        fieldRight.frame = CGRect(x: messageFieldX, y: fieldWrong.bottom + 20, width: messageFieldWidth, height: 200)
        tableView.frame = CGRect(x: messageFieldX, y: fieldRight.bottom + 20, width: messageFieldWidth, height: 200)
    }
    
    @objc private func buttonTapped() {
       dismiss(animated: true, completion: nil)
    }
    
    // MARK: функция проверки сообщения на грамматические ошибки
    func checkGrammar() {
        // считывание текста из fieldWrong
        let text = fieldWrong.text!
        // параметры
        let parameters = ["text": "\(text)", "language": "en-US"]
        // ссылка на languagetool
        let url = "https://api.languagetoolplus.com/v2/check"
        
        // асинхронно вызываем функцию запроса на сервис languagetool
        DispatchQueue.main.async {
            self.makeRequest(url: url, parameters: parameters, text: text)
        }
    }
    
    // MARK: TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mistakesArray.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = mistakesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // получаем для соответствующей ячейки таблицы ошибку и замену
        let message = grammarMistakeMessages[indexPath.row]
        let replacement = grammarMistakeReplacements[indexPath.row]
        
        // вызываем функцию с описанием ошибки и её предложенным исправлением
        showGrammarMistake(mistake: message!, replacement: replacement!)
    }

}


extension GrammarChatViewController {
    
    /// функция для вывода сообщения об ошибке
    func alertGrammarMistake(message: String = "") {
        let alert = UIAlertController(title: "You have a grammar mistake!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    /// функция для получения сообщения грамматической ошибки
    private func getMatchMessageMistake(value: Match) -> String {
        let res = value.message
        return res
    }
    
    /// функция для получения массива типа Replacement из массива типа Match
    private func getMatchArrayOfReplacements(value: Match) -> [Replacement] {
        let res = value.replacements
        return res
    }
    
    /// функция для получения значения предложенной замены ошибки из массива типа Replacement
    private func getMatchReplace(array: [Replacement]) -> String {
        let res = array[0].value
        return res
    }
    
    /// позиция слова с ошибкой
    private func getPositionOfWord(value: Match) -> Int {
        let res = value.offset
        return res
    }
    
    /// длина слова с ошибкой
    private func getLengthOfWord(value: Match) -> Int {
        let res = value.length
        return res
    }
    
    func showGrammarMistake(mistake: String, replacement: String) {
        let popupVC = GrammarMistakeViewController()
        
        popupVC.grammarMistakeDescription.text = "Грамматическая ошибка: \n \(mistake)"
        popupVC.grammarReplaceLabel.text = "Возможная замена \n \(replacement)"
        popupVC.modalPresentationStyle = .popover
        present(popupVC, animated: true)
    }
    
    
    // MARK: функция, осуществляющая запрос на languagetool
    public func makeRequest(url: String, parameters: [String: String], text: String) {
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON(completionHandler: { response in
            // полученные данные из запроса
            let result = response.data
            print(response)
            // array типа Match
            var grammarMistakes: [Match]
            // array типа Replacement
            var grammarReplacements: [Replacement]
            // index for tableView
            var index = 0
            
            do {
                // с помощью JSONDecoder переводим данные из полученного JSON в структуру Welcome
                let welcom = try! JSONDecoder().decode(Welcome.self, from: result!)
                
                let attributedString = NSMutableAttributedString(string: text)
                let newText = NSMutableAttributedString(string: text)
                var rangeDifference = 0
                // сохраняем в массив grammarMistakes данные из matches
                grammarMistakes = welcom.matches
                
                for mistake in grammarMistakes {
                    print(mistake.sentence)
                }
                
                for mistake in grammarMistakes {
                    /// сохраняем в массив grammarReplacements данные из grammarMistakes
                    grammarReplacements = self.getMatchArrayOfReplacements(value: mistake)
                    
                    /// получаем возможное исправление грамматической ошибки
                    let grammarReplaceMessage = self.getMatchReplace(array: grammarReplacements)
                    print("replace word: \(grammarReplaceMessage)")
                
                    /// получение позиции, где была допущена грамматическая ошибка
                    let position = self.getPositionOfWord(value: mistake)
                    
                    /// получение длины слова, в котором была допущена грамматическая ошибка
                    let length = self.getLengthOfWord(value: mistake)
                    
                    /// получение сообщения о грамматической ошибке
                    let grammarMistakeMessage = self.getMatchMessageMistake(value: mistake)
                    
                    /// заношу полученное сообщение в dictionaries сообщений об ошибках
                    self.grammarMistakeMessages.updateValue(grammarMistakeMessage, forKey: index)
                    self.grammarMistakeReplacements.updateValue(grammarReplaceMessage, forKey: index)
                    
                    /// выделение цветом грамматической ошибки
                    let range = NSRange(location: position, length: length)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "lightred"), range: range)
                    
                    
                    /// замена сообщения с ошибками на сообщение без ошибок
                    let searchString = (text as NSString).substring(with: range)
                    print(searchString)
                    let replacementString = grammarReplaceMessage
                    let newLength = grammarReplaceMessage.count
                    let newRange = NSRange(location: position + rangeDifference, length: length)
                    let newRangeColor = NSRange(location: position + rangeDifference, length: newLength)
                    
                    newText.mutableString.replaceOccurrences(of: searchString, with: replacementString, range: newRange)
                    newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: newRangeColor)
                    
                    rangeDifference += newLength - length
                    
                    // добавление в mistakesArray ошибки для последующего вывода в таблицу ошибок
                    self.mistakesArray.append(searchString)
                    index += 1
                }
                
                // изменяем сообщения в полях fieldWrong и fieldRight
                self.fieldWrong.attributedText = attributedString
                self.fieldWrong.font = UIFont.systemFont(ofSize: 18)
                self.fieldRight.attributedText = newText
                self.fieldRight.font = UIFont.systemFont(ofSize: 18)
                
                // обновление таблицы с ошибками
                self.tableView.reloadData()
            }
            catch {
                print("error in decode json!")
            }
        })
    }
    
    
}

