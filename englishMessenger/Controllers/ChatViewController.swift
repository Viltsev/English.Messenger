//
//  ChatViewController.swift
//  englishMessenger
//
//  Created by Данила on 19.02.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Foundation
import Alamofire

// structures for get data from JSON
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
    let id, subID, description: String
    let urls: [Replacement]
    let issueType: String
    let category: Category

    enum CodingKeys: String, CodingKey {
        case id
        case subID = "subId"
        case description, urls, issueType, category
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


struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
}


extension MessageKind {
    var messageKindString: String {
        switch self {
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        case .linkPreview(_):
            return "linkPreview"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
    
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .full
        format.timeStyle = .none
        format.locale = .current
        
        return format
    }()
    
    public var otherUserEmail: String
    private var conversationID: String?

    public var isNewConversation = false
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
                
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
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
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageID = createMessageId() else {
            return
        }
        // send message
        print("\(text)")
        
        
        // test grammar check api
        
        
//        let parameters = ["text": "\(text)", "language": "en-US"]
//        let url = "https://api.languagetoolplus.com/v2/check"
//        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON(completionHandler: { response in
//            // полученные данные из запроса
//            let result = response.data
//            // array типа Match
//            var grammarMistakes: [Match]
//            // array типа Replacement
//            var grammarReplacements: [Replacement]
//
//            do {
//                // с помощью JSONDecoder переводим данные из полученного JSON в структуру Welcome
//                let welcom = try JSONDecoder().decode(Welcome.self, from: result!)
//
//                // сохраняем в массив grammarMistakes данные из matches
//                grammarMistakes = welcom.matches
//
//                // получаем сообщение о грамматической ошибке
//                let grammarMistakeMessage = self.getMatchMessageMistake(array: grammarMistakes)
//
//                // сохраняем в массив grammarReplacements данные из grammarMistakes
//                grammarReplacements = self.getMatchArrayOfReplacements(array: grammarMistakes)
//
//                // получаем возможное исправление грамматической ошибки
//                let grammarReplaceMessage = self.getMatchReplace(array: grammarReplacements)
//
//                // alert с выводом грамматической ошибки
//                self.alertGrammarMistake(message: grammarMistakeMessage)
//
//
////                print("Грамматическая ошибка: \(grammarMistakeMessage)")
////                print("Как нужно исправить: \(grammarReplaceMessage)")
//            } catch {
//                print("error in decode json!")
//            }
//        })
        
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        
        if isNewConversation {
            // create conversation
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { success in
                if success {
                    print("message sent")
                    self.isNewConversation = false
                }
                else {
                    print("message didn't send")
                }
            })
        }
        else {
            guard let conversationID = conversationID, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
        }
        
    }
    
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let dateStringTest = ""
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateStringTest)"
        print("current message id: \(newIdentifier)")
        return newIdentifier
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        return Sender(photoURL: "",
                      senderId: "12",
                      displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
