//
//  Database.swift
//  englishMessenger
//
//  Created by Данила on 16.02.2023.
//

import Foundation
import FirebaseDatabase

// MARK: структура данных пользователя
//struct UserData {
//    public var email: String
//    public var name: String
//}

// MARK: структура данных пользователя
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

// MARK: класс Firebase Realtime Database
final class DatabaseManager {
    // экземпляр класса
    static let shared = DatabaseManager()
    
    // ссылка на БД
    private let database = Database.database().reference()
    
    // MARK: функция преобразования email пользователя к нужному для Firebase виду
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager {
    // MARK: функция получения данных пользователя по email (path: String)
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}

extension DatabaseManager {
    // MARK: функция-проверка, существует ли пользователь с таким email или нет
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
    
    // MARK: функция для записи нового пользователя в БД
    public func insertNewUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
        // запись пользователя в БД
        database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed out")
                completion(false)
                return
            }
            
            // получение данных о пользователе, записанного в БД
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // добавление пользователя в словарь
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    // в users добавляем словарь usersCollection
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                    
                }
                else {
                    // если пользователя не существует -> создание нового словаря
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
    
    // MARK: функция получения всех существующих пользователей
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    // MARK: функция получения имени и фамилии текущего пользователя
    public func getUserName(email: String, completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child("\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    // MARK: перечисление - ошибки базы данных
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}


extension DatabaseManager {
    // MARK: функция создание нового диалога
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        // получение почты текущего пользователя из UserDefaults
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        // преобразуем почту текущего пользователя к виду safeEmail (без точек и других неприемлимых символов)
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        // получаем ссылку на пользователя в БД
        let ref = database.child("\(safeEmail)")
        // чтение данных из БД
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
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
                    "name": name,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // данные о новом диалоге со стороны собеседника
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "latest_message": [
                    "date": dateString,
                    "name": currentName,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Обновление записи в БД диалога со стороны собеседника
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }
                else {
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            // Обновление текущего диалога пользователя
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
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
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
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        })
    }
    
    // MARK: функция завершения создания диалога
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
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
            "is_read": false,
            "name": name
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
    
    // MARK: функция получение всех диалогов пользователя по email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let name = latestMessage["name"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          return nil
                      }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationID,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        } )
    }
    
    // MARK: получение всех сообщений из данного диалога
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String else {
                          print("nil")
                          return nil
                      }
                // let date = ChatViewController.dateFormatter.date(from: dateString)
                
                let date = Date()
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
            })
            completion(.success(messages))
        } )
    }
    
    // MARK: функция обновления текущего уровня владения языком пользователя
    public func updateLevel() {
        // получение почты текущего пользователя из UserDefaults
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        // преобразуем почту текущего пользователя к виду safeEmail (без точек и других неприемлимых символов)
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let usersRef = self.database.child("\(safeEmail)")
        let userLevel = UserDefaults.standard.value(forKey: "englishLevel") as? String
        usersRef.child("level").setValue(userLevel)
        
    }
    
    
//    public func getLevel(for email: String, completion: @escaping (String?, Error?) -> Void) {
//        database.child("\(email)/level").observe(.value) { snapshot in
//            guard let value = snapshot.value as? String else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//
//            completion(.success(value))
//        }
//    }
    
    // MARK: функция получения текущего уровня владения языком пользователя
    func getLevel(for email: String, completion: @escaping (String?, Error?) -> Void) {
        database.child("\(email)").child("level").observeSingleEvent(of: .value) { (snapshot, error) in
            if let level = snapshot.value as? String {
                completion(level, nil)
            } else {
                print("error")
            }
        } withCancel: { (error) in
            completion(nil, error)
        }
    }
    
//    public func getLevel(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
//        database.child("\(email)/conversations").observe(.value, with: { snapshot in
//            guard let value = snapshot.value as? [[String: Any]] else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//
//            let conversations: [Conversation] = value.compactMap({ dictionary in
//                guard let conversationID = dictionary["id"] as? String,
//                      let otherUserEmail = dictionary["other_user_email"] as? String,
//                      let latestMessage = dictionary["latest_message"] as? [String: Any],
//                      let date = latestMessage["date"] as? String,
//                      let name = latestMessage["name"] as? String,
//                      let message = latestMessage["message"] as? String,
//                      let isRead = latestMessage["is_read"] as? Bool else {
//                          return nil
//                      }
//
//                let latestMessageObject = LatestMessage(date: date,
//                                                        text: message,
//                                                        isRead: isRead)
//                return Conversation(id: conversationID,
//                                    name: name,
//                                    otherUserEmail: otherUserEmail,
//                                    latestMessage: latestMessageObject)
//            })
//            completion(.success(conversations))
//        } )
//    }
    
    
    // MARK: функция отправки сообщений пользователю
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // 1. добавление сообщения в messages
        // 2. обновление "latest message" отправителя
        // 3. обновление "latest message"
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            
            
            // дата отправления сообщения
            let messageDate = newMessage.sentDate
            // преобразуем дату к нужному формату по dateFormatter
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind {
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
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": "",
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages,
                                                                           withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message,
                        "name": name
                    ]
                    
                    var targetConversation: [String: Any]?
                    var position = 0
                    
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentID = conversationDictionary["id"] as? String, currentID == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    
                    currentUserConversations[position] = finalConversation
                    print("finalConvo: ", finalConversation)
                    print("position: ", position)
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        
                        // обновление latest message для собеседника
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }

                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }
                            
                            print("sender name: \(currentName)")
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message,
                                "name": currentName
                            ]

                            var targetConversation: [String: Any]?
                            var position = 0


                            for conversationDictionary in otherUserConversations {
                                if let currentID = conversationDictionary["id"] as? String, currentID == conversation {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }

                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }

                            otherUserConversations[position] = finalConversation
                            print("finalConvo: ", finalConversation)
                            print("position: ", position)
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }

                                completion(true)
                            })
                        })
                        
                        // completion(true)
                    })
                })
            })
        })
    }
}



