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

// MARK: протокол SendMessage для отправки сообщения пользователю
protocol SendMessage {
    func sendMessage(message: String)
}

// MARK: структура сообщения пользователя
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

// MARK: структура пользователя-отправителя сообщения
struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}


class ChatViewController: MessagesViewController {
    
    // текст сообщения пользователя
    var userMessage: String = ""
    // проверка, отправлено сообщение или нет
    var checkSend: Bool = false
    // делегат протокола SendMessage
    var delegate: SendMessage?
    
    // дата в сообщении (на данный момент не используется)
    public static let dateFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .full
        format.timeStyle = .none
        format.locale = .current
        
        return format
    }()
    
    // email пользователя-получателя сообщения
    public var otherUserEmail: String
    
    // id диалога
    private var conversationID: String?
    
    // проверка, новый ли это диалог или нет
    public var isNewConversation = false
    
    // массив сообщений пользователя типа Message
    private var messages = [Message]()
    
    // экземпляр структуры Sender - пользователь-отправитель сообщения
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
        configureMessageInputBarCheck()
        view.backgroundColor = .red
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(grammarExplain))

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    // MARK: функция перехода в окно с проверкой грамматики сообщения
    @objc func grammarExplain() {
        UserDefaults.standard.set(userMessage, forKey: "userMessage")
        let vc = GrammarChatViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: функция получения сообщений из диалога по id диалога
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("empty")
                    return
                }
                
                // сообщения текущего диалога
                self?.messages = messages
                
                DispatchQueue.main.async {
                    // обновление сообщений диалога
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        // скролл на последнее сообщение диалога
                        self?.messagesCollectionView.scrollToLastItem(animated: true)
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
    
    // MARK: функция кнопки проверки грамматики сообщения
    func configureMessageInputBarCheck() {
        messageInputBar.delegate = self
        messageInputBar.sendButton.title = "Check"
    }
    
    // MARK: функция кнопки отправления сообщения
    func configureMessageInputBarSend() {
        messageInputBar.delegate = self
        messageInputBar.sendButton.title = "Send"
    }
}

// MARK: extension для ChatViewController
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    // MARK: функция ввода сообщения в inputBar диалога
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // считывание данных
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageID = createMessageId() else {
            return
        }
        // текст сообщения пользователя
        userMessage = text
        
        // формирование переменной сообщения типа Message
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        
        if checkSend {
            // если диалог новый
            if isNewConversation {
                // создаем новый диалог
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
                // отправка сообщения пользователю
                DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
                    if success {
                        print("message sent")
                    }
                    else {
                        print("failed to send")
                    }
                })
            }
            // очищение inputBar диалога
            messageInputBar.inputTextView.text = ""
            configureMessageInputBarCheck()
            checkSend = false
        }
        else {
            configureMessageInputBarSend()
            checkSend = true
        }
        
        
    }
    
    // MARK: функция создания id сообщения 
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
