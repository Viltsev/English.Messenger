//
//  Database.swift
//  englishMessenger
//
//  Created by Данила on 16.02.2023.
//

import Foundation
import FirebaseDatabase


final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()

    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


/// Inserting new users
extension DatabaseManager {
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard (snapshot.value as? String) != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    
//    public func insertNewUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
//        database.child(user.safeEmail).setValue([
//            "firstName": user.firstName,
//            "lastName": user.lastName
//        ])
//    }
    
    
    public func insertNewUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed out")
                completion(false)
                return
            }
            
            /// получение данных о пользователе
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // добавление пользователя в словарь
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                    
                }
                else {
                    // создание нового словаря
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            return
                        }
                    })
                }
            })
            
            completion(true)
        })
    }
    
    /// функция получения всех существующих пользователей
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    /// перечисление - ошибки базы данных
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}


extension DatabaseManager {
    
    /// создание нового диалога
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        // получение почты текущего пользователя из UserDefaults
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        // преобразуем почту текущего пользователя к виду safeEmail (без точек и других неприемлимых символов)
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        // получаем ссылку на пользователя в БД
        let ref = database.child("\(safeEmail)")
        // чтение данных из БД
        ref.observeSingleEvent(of: .value, with: { snapshot in
            // проверка, есть ли пользователь
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            // дата отправления сообщения
            let messageDate = firstMessage.sentDate
            // преобразуем дату к нужному формату по dateFormatter
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            // получение ID диалога
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            // данные о новом диалоге
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // существует диалог для текущего пользователя
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    // вызов функции завершения создания диалога
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
            else {
                // создание диалога
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    // вызов функции завершения создания диалога
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
        })
    }
    
    /// функция завершения создания диалога
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        // дата отправления сообщения
        let messageDate = firstMessage.sentDate
        // преобразуем дату к нужному формату по dateFormatter
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        // получение почты текущего пользователя из UserDefaults
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        // преобразование почты текущего пользователя к "безопасному" виду
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": "",
            "sender_email": currentUserEmail,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    /// получение всех диалогов пользователя по email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// получение всех сообщений из данного диалога
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    
    /// отправка сообщений пользователю
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}


struct AppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
