//
//  TestViewController.swift
//  englishMessenger
//
//  Created by Данила on 16.02.2023.
//

import UIKit
import Alamofire

//struct TranslateData: Codable {
//    let data: MainData
//}
//
//struct MainData: Codable {
//    let translatedText: String
//}

class TestViewController: UIViewController {
    
//    // MARK: Network
//    let session = URLSession.shared
//    let decoder = JSONDecoder()
//
//
//    // MARK: UI
//    private let buttonSend: UIButton = {
//        let button = UIButton()
//        button.setTitle("Translate", for: .normal)
//        button.backgroundColor = .systemPurple
//
//        button.titleLabel?.font = UIFont(name: "Optima", size: 24)
//        button.layer.cornerRadius = 12
//        button.layer.masksToBounds = true
//        return button
//    }()
//
//    private let textFieldSource: UITextView = {
//        let field = UITextView()
//        field.font = UIFont.systemFont(ofSize: 18)
//        field.layer.borderWidth = 0.5
//        field.layer.cornerRadius = 15
//        field.layer.borderColor = UIColor.systemPink.cgColor
//        field.sizeToFit()
//        return field
//    }()
//
//    private let textFieldTarget: UITextView = {
//        let field = UITextView()
//        field.text = "translation here"
//        field.font = UIFont.systemFont(ofSize: 18)
//        field.layer.borderWidth = 0.5
//        field.layer.cornerRadius = 15
//        field.layer.borderColor = UIColor.green.cgColor
//        field.sizeToFit()
//        return field
//    }()
//
//    // MARK: viewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//
//
//        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
//        button.tintColor = .systemPink
//        navigationItem.leftBarButtonItem = button
//
//        buttonSend.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
//
//        // placement of UI-elements
//        view.addSubview(textFieldSource)
//        view.addSubview(textFieldTarget)
//        view.addSubview(buttonSend)
//    }
//
//    // MARK: UI-positions
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let messageFieldWidth = view.frame.size.width - 20
//        let messageFieldX = view.frame.size.width/2 - messageFieldWidth / 2
//        textFieldSource.frame = CGRect(x: messageFieldX,
//                                       y: view.safeAreaInsets.top + 10,
//                                       width: messageFieldWidth,
//                                       height: 70)
//        textFieldTarget.frame = CGRect(x: messageFieldX,
//                                       y: textFieldSource.bottom + 20,
//                                       width: messageFieldWidth,
//                                       height: 70)
//        buttonSend.frame = CGRect(x: messageFieldX, y: textFieldTarget.bottom + 20, width: 250, height: 70)
//    }
//
//    // MARK: Back to previous view function
//    @objc private func buttonTapped() {
//       dismiss(animated: true, completion: nil)
//    }
//
//    @objc private func sendButtonTapped() {
//
//        DispatchQueue.main.async {
//            self.obtainData()
//        }
//
//    }
//
//}
//
//extension TestViewController {
//    // MARK: Network Part
//
//    func obtainData() {
//        let text = textFieldSource.text
//
//        let headers = [
//            "content-type": "application/x-www-form-urlencoded",
//            "X-RapidAPI-Key": "cd02c58415mshb53743187d9ff8ap1c314fjsn07806753884e",
//            "X-RapidAPI-Host": "text-translator2.p.rapidapi.com"
//        ]
//
//        let postData = NSMutableData(data: "source_language=ru".data(using: String.Encoding.utf8)!)
//        postData.append("&target_language=en".data(using: String.Encoding.utf8)!)
//        postData.append("&text=\(text!)".data(using: String.Encoding.utf8)!)
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://text-translator2.p.rapidapi.com/translate")! as URL,
//                                                cachePolicy: .useProtocolCachePolicy,
//                                            timeoutInterval: 10.0)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
//
//            guard let strongSelf = self else { return }
//
//            if error == nil, let parseData = data {
//                let responseData = try? strongSelf.decoder.decode(TranslateData.self, from: parseData)
//                let translate = responseData?.data.translatedText
//                DispatchQueue.main.async {
//                    strongSelf.textFieldTarget.text = translate
//                }
//            }
//            else {
//                print("error!!")
//            }
//
//        })
//
//        dataTask.resume()
//    }
    
    
}

