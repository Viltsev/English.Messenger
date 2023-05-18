//
//  MultithreadingViewController.swift
//  englishMessenger
//
//  Created by Данила on 05.05.2023.
//

import UIKit

class MultithreadingViewController: UIViewController {
    
    private var threadClass: MyThread?
    // private var threadClassSecond: MySecondThread?
    private let lock = NSLock()
    private var isLocked = false
    
    public let myLabel: UILabel = {
        let field = UILabel()
        field.text = "numbers here"
        field.textAlignment = .center
        return field
    }()
    
    private let startThread: UIButton = {
        let button = UIButton()
        button.setTitle("запустить поток", for: .normal)
        button.backgroundColor = .systemBlue
        
        button.titleLabel?.font = UIFont(name: "Optima", size: 18)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let stopThread: UIButton = {
        let button = UIButton()
        button.setTitle("завершить поток", for: .normal)
        button.backgroundColor = .systemRed
        
        button.titleLabel?.font = UIFont(name: "Optima", size: 18)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let lockThreadButton: UIButton = {
            let button = UIButton()
            button.setTitle("Блокировать поток", for: .normal)
            button.backgroundColor = .systemOrange
            button.titleLabel?.font = UIFont(name: "Optima", size: 18)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(myLabel)
        view.addSubview(startThread)
        view.addSubview(stopThread)
        // view.addSubview(lockThreadButton)
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        // Do any additional setup after loading the view.
        startThread.addTarget(self, action: #selector(startThreadAction), for: .touchUpInside)
        stopThread.addTarget(self, action: #selector(stopThreadAction), for: .touchUpInside)
        // lockThreadButton.addTarget(self, action: #selector(lockThreadAction), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        myLabel.frame = CGRect(x: view.frame.midX - 100,
                               y: view.frame.midY,
                               width: 200,
                               height: 50)
        startThread.frame = CGRect(x: myLabel.frame.midX - 125, y: myLabel.bottom + 20, width: 250, height: 70)
        stopThread.frame = CGRect(x: myLabel.frame.midX - 125, y: startThread.bottom + 30, width: 250, height: 70)
        // lockThreadButton.frame = CGRect(x: myLabel.frame.midX - 125, y: stopThread.bottom + 30, width: 250, height: 70)
    }
    
    @objc private func startThreadAction() {
        threadClass = MyThread(diffClass: self)
        threadClass?.start()
    }
    
    @objc private func stopThreadAction() {
        threadClass?.cancel()
        threadClass = nil
    }
    
    @objc private func buttonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
//    @objc private func lockThreadAction() {
//        if isLocked {
//            isLocked = false
//            lock.unlock()
//            lockThreadButton.setTitle("Блокировать поток", for: .normal)
//        } else {
//            isLocked = true
//            lock.lock()
//            lockThreadButton.setTitle("Разблокировать поток", for: .normal)
//            DispatchQueue.global().async {
//                self.performLockedTask()
//            }
//        }
//    }
    
}


class MyThread: Thread {
    weak var diffClass: MultithreadingViewController?

    init(diffClass: MultithreadingViewController) {
        self.diffClass = diffClass
        super.init()
    }

    override func main() {
        for i in 1...1000 {
            guard let diffClass = diffClass, !isCancelled else {
                break
            }
            
            DispatchQueue.main.async {
                diffClass.myLabel.text = "number \(i)"
            }
            
            Thread.sleep(forTimeInterval: 2)
        }
    }
    
}

//class MySecondThread: Thread {
//    weak var diffClass: MultithreadingViewController?
//
//    init(diffClass: MultithreadingViewController) {
//        self.diffClass = diffClass
//        super.init()
//    }
//
//    override func main() {
//        for i in 1...1000 {
//            guard let diffClass = diffClass, !isCancelled else {
//                break
//            }
//
//            DispatchQueue.main.async {
//                diffClass.myLabel.text = "new number \(i)"
//            }
//
//            Thread.sleep(forTimeInterval: 2)
//        }
//    }
//}

