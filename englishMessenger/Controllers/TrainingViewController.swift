//
//  TrainingViewController.swift
//  englishMessenger
//
//  Created by Данила on 18.03.2023.
//

import UIKit
import Alamofire

// MARK: структуры данных из JSON

// MARK: - родительская структура
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
    
    // словарь для хранения сообщений о грамматических ошибках
    var grammarMistakeMessages: [Int: String] = [-1: ""]
    
    // словарь для хранения сообщений о том, как можно исправить грамматическую ошибку
    var grammarMistakeReplacements: [Int: String] = [-1: ""]
    
    // MARK: UI-элементы
    
    private let buttonSend: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .systemPurple
        
        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let textField: UITextView = {
        let textField = UITextView()
        textField.textContainer.maximumNumberOfLines = 0
        textField.textContainer.lineBreakMode = .byWordWrapping
        textField.text = "Enter text here"
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.autocorrectionType = .no
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        // добавление функции sendButtonTapped к кнопке отправки текста
        buttonSend.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        textField.returnKeyType = .done
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(_:)))
        textField.addGestureRecognizer(tapGesture)
        
        
        view.addSubview(textField)
        view.addSubview(buttonSend)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
        textField.frame = CGRect(x: view.bounds.midX - 150, y: view.bounds.minY + 100, width: 300, height: 300)
        buttonSend.frame = CGRect(x: textField.left + 25, y: textField.bottom + 20, width: 250, height: 70)
    }
    
    
    @objc private func buttonTapped() {
       dismiss(animated: true, completion: nil)
    }
    
    @objc func textViewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // Get the NSRange of the selected text
            if let selectedRange = textField.selectedTextRange {
                let start = selectedRange.start
                let end = selectedRange.end
                let startIndex = textField.offset(from: textField.beginningOfDocument, to: start)
                let length = textField.offset(from: start, to: end)
                // let position = textField.position(from: start, offset: length)
                let selectedText = (textField.text as NSString).substring(with: NSRange(location: startIndex, length: length))
                // Perform an action on the selected text
                print("Selected Text: \(selectedText)")
                
                if !selectedText.isEmpty {
                    
                    
                    guard let message = grammarMistakeMessages[startIndex],
                          let replacement = grammarMistakeReplacements[startIndex] else {
                        return
                    }
                    
                    showGrammarMistake(mistake: message, replacement: replacement)
                }
            }
        }
    }
    
    /*
     Hello,
     My name is Susan. I'm forteen and I life in Germany. My hobbys are go to discos and jogging, sometimes I hear music in the radio. In the July I go swimming in a sea . I haven't any brothers or sisters. We take busses to scool. I visit year 9 at my school. My birthday is on Friday. I hope I will become a new guitar.
     I'm looking forward to get a e-mail from you.
    */

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
    }
    
    func showGrammarMistake(mistake: String, replacement: String) {
        let popupVC = GrammarMistakeViewController()
        
        popupVC.grammarMistakeDescription.text = "Грамматическая ошибка: \n \(mistake)"
        popupVC.grammarReplaceLabel.text = "Возможная замена \n \(replacement)"
        popupVC.modalPresentationStyle = .popover
        present(popupVC, animated: true)
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
    
    private func makeRequest(url: String, parameters: [String: String], text: String) {
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
                    attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor(named: "lightred"), range: range)
                    
                }
                
                self.textField.attributedText = attributedString
                self.textField.font = UIFont.systemFont(ofSize: 18)
                print(self.grammarMistakeMessages)
            }
            catch {
                print("error in decode json!")
            }
        })
    }
    
    @objc private func sendButtonTapped() {
        let text = textField.text!
        
        let parameters = ["text": "\(text)", "language": "en-US"]
        print(parameters)
        let url = "https://api.languagetoolplus.com/v2/check"
        
        DispatchQueue.main.async {
            self.makeRequest(url: url, parameters: parameters, text: text)
        }
        
        
        
    }
    
}
