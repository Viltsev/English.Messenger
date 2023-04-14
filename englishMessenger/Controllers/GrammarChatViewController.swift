//
//  GrammarChatViewController.swift
//  englishMessenger
//
//  Created by Данила on 13.04.2023.
//

import UIKit
import Alamofire

class GrammarChatViewController: UIViewController {

    /// словарь для хранения сообщений о грамматических ошибках
    var grammarMistakeMessages: [Int: String] = [-1: ""]
    /// словарь для хранения сообщений о том, как можно исправить грамматическую ошибку
    var grammarMistakeReplacements: [Int: String] = [-1: ""]
    
//    var data: [String] = ["Example"]
//    var tableView: UITableView!
//    let cellReuseIdentifier = "cell"
    
    
    private let fieldWrong: UITextView = {
        let field = UITextView()
        field.text = "message here"
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor.systemPink.cgColor
        field.sizeToFit()
        return field
    }()
    
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
        view.addSubview(fieldWrong)
        view.addSubview(fieldRight)
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        title = "Test"
        view.backgroundColor = .white
        
        fieldWrong.dataDetectorTypes = UIDataDetectorTypes.all
        fieldWrong.isEditable = false
        
        fieldWrong.text = UserDefaults.standard.value(forKey: "userMessage") as? String
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
    }
    
    @objc private func buttonTapped() {
       dismiss(animated: true, completion: nil)
    }
    
    func checkGrammar() {
        let text = fieldWrong.text!
        
        let parameters = ["text": "\(text)", "language": "en-US"]
        print(parameters)
        let url = "https://api.languagetoolplus.com/v2/check"
        
        DispatchQueue.main.async {
            self.makeRequest(url: url, parameters: parameters, text: text)
        }
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
    
    
    
    public func makeRequest(url: String, parameters: [String: String], text: String) {
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON(completionHandler: { response in
            // полученные данные из запроса
            let result = response.data
            print(response)
            // array типа Match
            var grammarMistakes: [Match]
            // array типа Replacement
            var grammarReplacements: [Replacement]
            //
            
            do {
                // с помощью JSONDecoder переводим данные из полученного JSON в структуру Welcome
                let welcom = try! JSONDecoder().decode(Welcome.self, from: result!)
                
                let attributedString = NSMutableAttributedString(string: text)
                
                
                
                
                // сохраняем в массив grammarMistakes данные из matches
                grammarMistakes = welcom.matches
                
                for mistake in grammarMistakes {
                    print(mistake.offset)
                }
                
                for mistake in grammarMistakes {
                    /// сохраняем в массив grammarReplacements данные из grammarMistakes
                    grammarReplacements = self.getMatchArrayOfReplacements(value: mistake)
                    
                    /// получаем возможное исправление грамматической ошибки
                    let grammarReplaceMessage = self.getMatchReplace(array: grammarReplacements)

                    /// получение позиции, где была допущена грамматическая ошибка
                    let position = self.getPositionOfWord(value: mistake)
                    
                    /// получение длины слова, в котором была допущена грамматическая ошибка
                    let length = self.getLengthOfWord(value: mistake)
                    
                    /// получение сообщения о грамматической ошибке
                    let grammarMistakeMessage = self.getMatchMessageMistake(value: mistake)
                    
                    /// заношу полученное сообщение в dictionaries сообщений об ошибках
                    self.grammarMistakeMessages.updateValue(grammarMistakeMessage, forKey: position)
                    self.grammarMistakeReplacements.updateValue(grammarReplaceMessage, forKey: position)
                    
                    /// выделение цветом грамматической ошибки
                    let range = NSRange(location: position, length: length)
                    
                    
                    let linkAttributes: [NSAttributedString.Key: Any] = [.link: self.showGrammarMistake(mistake: grammarMistakeMessage, replacement: grammarReplaceMessage)]
                    attributedString.addAttributes(linkAttributes, range: range)
                    
                }
                
                self.fieldWrong.attributedText = attributedString
                self.fieldWrong.font = UIFont.systemFont(ofSize: 18)
                
                print(self.grammarMistakeMessages)
            }
            catch {
                print("error in decode json!")
            }
        })
    }
    
    
}

