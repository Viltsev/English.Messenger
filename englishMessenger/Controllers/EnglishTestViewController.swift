//
//  EnglishTestViewController.swift
//  englishMessenger
//
//  Created by Данила on 08.04.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: протокол для передачи кол-ва баллов, полученных за тест в TestResultsViewController
protocol Level {
    func sendPoints(amount: Int)
}

class EnglishTestViewController: UIViewController, UITextFieldDelegate {
    var delegate: Level?
    
    let database = Firestore.firestore()
    /// текущий ответ
    var currentAnswer = ""
    /// номер вопроса
    var numOfQuesString = ""
    var numOfQues = 1
    /// выбранный вариант ответа
    var selectedButton: Int = 0
    /// кол-во вопросов
    var questionsAmount = 0
    /// словарь ответов пользователя
    var userAnswers: [String: String] = ["": ""]
    /// словарь с правильными вариантами ответов
    var rightAnswers: [String: String] = ["": ""]
    
    
    // MARK: основные UI-элементы
    private let answerButtonFirst: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let answerButtonSecond: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let answerButtonThird: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let answerButtonFourth: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let nextQuestionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next Question", for: .normal)
        button.backgroundColor = UIColor(named: "darkgreen")
        button.layer.cornerRadius = 15
        return button
    }()
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter text..."
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(answerButtonFirst)
        view.addSubview(answerButtonSecond)
        view.addSubview(answerButtonThird)
        view.addSubview(answerButtonFourth)
        view.addSubview(nextQuestionButton)
        
        answerButtonFirst.addTarget(self, action: #selector(answerButtonFirstClick), for: .touchUpInside)
        answerButtonSecond.addTarget(self, action: #selector(answerButtonSecondClick), for: .touchUpInside)
        answerButtonThird.addTarget(self, action: #selector(answerButtonThirdClick), for: .touchUpInside)
        answerButtonFourth.addTarget(self, action: #selector(answerButtonFourthClick), for: .touchUpInside)
        nextQuestionButton.addTarget(self, action: #selector(nextQuestionButtonClick), for: .touchUpInside)
        
        field.delegate = self
        title = "Test"
        view.backgroundColor = .white
        
        getQuestion(quesNum: numOfQues)
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        field.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.frame.size.width-20, height: 50)
        label.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 70, width: view.frame.size.width-20, height: 100)
        answerButtonFirst.frame = CGRect(x: view.bounds.midX - 125, y: view.safeAreaInsets.top + 200, width: 250, height: 50)
        answerButtonSecond.frame = CGRect(x: view.bounds.midX - 125, y: answerButtonFirst.bottom + 20, width: 250, height: 50)
        answerButtonThird.frame = CGRect(x: view.bounds.midX - 125, y: answerButtonSecond.bottom + 20, width: 250, height: 50)
        answerButtonFourth.frame = CGRect(x: view.bounds.midX - 125, y: answerButtonThird.bottom + 20, width: 250, height: 50)
        nextQuestionButton.frame = CGRect(x: view.bounds.midX - 125, y: answerButtonFourth.bottom + 60, width: 250, height: 50)
    }
    
    // MARK: функция записи данных в Firestore
    // text - ответ пользователя
    // quesNum - номер вопроса
    func saveData(text: String, quesNum: Int) {
        /// получаем из UserDefaults почту текущего пользователя
        let currentEmail = UserDefaults.standard.value(forKey: "email") as! String
        /// записываем данные для конкретного пользователя
        let docRef = database.document("englishTest/\(currentEmail)")
        docRef.setData(["Question \(quesNum)": text], merge: true)
    }
    
    // MARK: функция получения данных из Firestore
    func getQuestion(quesNum: Int) {
        /// получаем доступ к документу в Firestore по заданному пути
        let docRef = database.document("englishTest/questions")
        /// с помощью addSnapshotListener считываем данные из БД
        docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            /// кол-во вопросов в БД
            self?.questionsAmount = data.count
            
            /// получаем из data вопрос с переданным в функцию номером вопроса
            guard let text = data["Question \(quesNum)"] as? [String: Any] else {
                    return
            }
            
            self?.numOfQuesString = "Question \(quesNum)"
            
            /// записываем данные полученные в text в соответствующие элементы для дальнейшего отображения
            DispatchQueue.main.async {
                self?.label.text = text["question"] as? String
                self?.answerButtonFirst.setTitle(text["answer1"] as? String, for: .normal)
                self?.answerButtonSecond.setTitle(text["answer2"] as? String, for: .normal)
                self?.answerButtonThird.setTitle(text["answer3"] as? String, for: .normal)
                self?.answerButtonFourth.setTitle(text["answer4"] as? String, for: .normal)
                self?.rightAnswers["Question \(quesNum)"] = text["rightAnswer"] as? String
            }
        }
    }
    
    // MARK: функции нажатия кнопок выбора варианта ответа
    @objc func answerButtonFirstClick() {
        answerButtonFirst.backgroundColor = .green
        self.selectedButton = 1
        answerButtonSecond.backgroundColor = .systemPink
        answerButtonThird.backgroundColor = .systemPink
        answerButtonFourth.backgroundColor = .systemPink
        currentAnswer = "answer1"
        userAnswers[numOfQuesString] = currentAnswer
    }
    
    @objc func answerButtonSecondClick() {
        answerButtonSecond.backgroundColor = .green
        self.selectedButton = 2
        answerButtonFirst.backgroundColor = .systemPink
        answerButtonThird.backgroundColor = .systemPink
        answerButtonFourth.backgroundColor = .systemPink
        currentAnswer = "answer2"
        userAnswers[numOfQuesString] = currentAnswer
    }
    
    @objc func answerButtonThirdClick() {
        answerButtonThird.backgroundColor = .green
        self.selectedButton = 3
        answerButtonSecond.backgroundColor = .systemPink
        answerButtonFirst.backgroundColor = .systemPink
        answerButtonFourth.backgroundColor = .systemPink
        currentAnswer = "answer3"
        userAnswers[numOfQuesString] = currentAnswer
    }
    
    @objc func answerButtonFourthClick() {
        answerButtonFourth.backgroundColor = .green
        self.selectedButton = 4
        answerButtonSecond.backgroundColor = .systemPink
        answerButtonThird.backgroundColor = .systemPink
        answerButtonFirst.backgroundColor = .systemPink
        currentAnswer = "answer4"
        userAnswers[numOfQuesString] = currentAnswer
    }

    // MARK: функция перехода к следующему вопросу
    @objc func nextQuestionButtonClick() {
        /// сохраняем полученный ответ пользователя на вопрос в Firestore
        saveData(text: self.currentAnswer, quesNum: self.numOfQues)
        self.numOfQues += 1
        /// получаем следующий вопрос
        getQuestion(quesNum: numOfQues)
        /// обновляем кнопки вариантов ответа
        switch selectedButton {
        case 1:
            answerButtonFirst.backgroundColor = .systemPink
        case 2:
            answerButtonSecond.backgroundColor = .systemPink
        case 3:
            answerButtonThird.backgroundColor = .systemPink
        case 4:
            answerButtonFourth.backgroundColor = .systemPink
        case 0:
            break
        default:
            break
        }
        
        /// если все вопросы закончились, тогда передаем полученные данные в TestResultsVC
        if self.numOfQues > self.questionsAmount {
            let points = getPoints()
            delegate?.sendPoints(amount: points)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: функция проверки уровня знания языка
    // возвращает кол-во баллов, набранных за тест
    func getPoints() -> Int {
        var points = 0
        for i in 1...questionsAmount {
            if userAnswers["Question \(i)"] == rightAnswers["Question \(i)"] {
                points += 1
            }
        }
        return points
    }
}


