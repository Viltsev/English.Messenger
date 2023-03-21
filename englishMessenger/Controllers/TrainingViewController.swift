//
//  TrainingViewController.swift
//  englishMessenger
//
//  Created by Данила on 18.03.2023.
//

import UIKit
import Alamofire

// MARK: structures for get data from JSON

// MARK: - Welcome
struct Welcome: Codable {
    let software: Software
    let language: Language
    let matches: [Match]
}

// MARK: - Language
struct Language: Codable {
    let name, code: String
    let detectedLanguage: DetectedLanguage
}

// MARK: - DetectedLanguage
struct DetectedLanguage: Codable {
    let name, code: String
}

// MARK: - Match
struct Match: Codable {
    let message, shortMessage: String
    let offset, length: Int
    let replacements: [Replacement]
    let context: Context
    let sentence: String
    let rule: Rule
}

// MARK: - Context
struct Context: Codable {
    let text: String
    let offset, length: Int
}

// MARK: - Replacement
struct Replacement: Codable {
    let value: String
}

// MARK: - Rule
struct Rule: Codable {
    let id, description: String
//    let urls: [Replacement]
    let issueType: String
    let category: Category

    enum CodingKeys: String, CodingKey {
        case id
        case description, issueType, category
    }
}

// MARK: - Category
struct Category: Codable {
    let id, name: String
}

// MARK: - Software
struct Software: Codable {
    let name, version, buildDate: String
    let apiVersion: Int
    let status: String
    let premium: Bool
}


class TrainingViewController: UIViewController, UITextFieldDelegate {

    private let buttonSend: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .systemPurple
        
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        buttonSend.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        textField.delegate = self
        textField.placeholder = "Enter text"
        textField.returnKeyType = .done
        view.addSubview(textField)
        view.addSubview(buttonSend)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
        textField.frame = CGRect(x: view.bounds.midX - 125, y: view.bounds.minY + 100, width: 250, height: 100)
        buttonSend.frame = CGRect(x: textField.left, y: textField.bottom + 20, width: 250, height: 70)
    }
    
    
    @objc private func buttonTapped() {
       dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
    }
}


extension TrainingViewController {
    
    /// grammar checker functions
    ///
    /// функция для вывода сообщения об ошибке
    func alertGrammarMistake(message: String = "") {
        let alert = UIAlertController(title: "You have a grammar mistake!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    /// функция для получения сообщения грамматической ошибки
    private func getMatchMessageMistake(array: [Match]) -> String {
        let res = array[0].message
        return res
    }
    
    /// функция для получения массива типа Replacement из массива типа Match
    private func getMatchArrayOfReplacements(array: [Match]) -> [Replacement] {
        let res = array[0].replacements
        return res
    }
    
    /// функция для получения значения предложенной замены ошибки из массива типа Replacement
    private func getMatchReplace(array: [Replacement]) -> String {
        let res = array[0].value
        return res
    }
    
    private func getReplaceWord(array: [Match]) -> Int {
        let res = array[0].offset
        return res
    }
    
    @objc private func sendButtonTapped() {
        let text = textField.text!
        
        let parameters = ["text": "\(text)", "language": "en-US"]
        print(parameters)
        let url = "https://api.languagetoolplus.com/v2/check"
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON(completionHandler: { response in
            // полученные данные из запроса
            let result = response.data
            print(response)
            // array типа Match
            var grammarMistakes: [Match]
            // array типа Replacement
            var grammarReplacements: [Replacement]

            do {
                // с помощью JSONDecoder переводим данные из полученного JSON в структуру Welcome
                let welcom = try! JSONDecoder().decode(Welcome.self, from: result!)

                // сохраняем в массив grammarMistakes данные из matches
                grammarMistakes = welcom.matches
                print(grammarMistakes)
                // получаем сообщение о грамматической ошибке
                let grammarMistakeMessage = self.getMatchMessageMistake(array: grammarMistakes)

                // сохраняем в массив grammarReplacements данные из grammarMistakes
                grammarReplacements = self.getMatchArrayOfReplacements(array: grammarMistakes)

                // получаем возможное исправление грамматической ошибки
                let grammarReplaceMessage = self.getMatchReplace(array: grammarReplacements)

                // alert с выводом грамматической ошибки
                self.alertGrammarMistake(message: grammarMistakeMessage)

                // получение позиции, где была допущена грамматическая ошибка
                let position = self.getReplaceWord(array: grammarMistakes)
                
                // получение позиции в textField, где была допущена ошибка
                let mistakePosition = self.textField.position(from: self.textField.beginningOfDocument, offset: position)
                
                // выделение диапозона в textField с ошибочным словом
                let wordRange = self.textField.tokenizer.rangeEnclosingPosition(mistakePosition!, with: .word, inDirection: .init(rawValue: 0))
                
                // само слово с ошибкой
                let word = self.textField.text(in: wordRange!)
                
                
                // выделение цветом грамматической ошибки
                let attributedString = NSMutableAttributedString(string: text)
                let range = (text as NSString).range(of: "\(word!)")
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.red, range: range)
                self.textField.attributedText = attributedString
                self.textField.reloadInputViews()
                
            } catch {
                print("error in decode json!")
            }
        })
    }

    
    
    
}
