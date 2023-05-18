//
//  SecondThreadViewController.swift
//  englishMessenger
//
//  Created by Данила on 13.05.2023.
//

import UIKit

class SecondThreadViewController: UIViewController {

    private let numberLabels: [UILabel] = {
        var labels = [UILabel]()
        for i in 0..<5 {
            let label = UILabel()
            label.textAlignment = .center
            label.text = "result of task here"
            label.font = UIFont.systemFont(ofSize: 24)
            label.tag = i
            labels.append(label)
        }
        return labels
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(startThread)
        startThread.addTarget(self, action: #selector(startThreadAction), for: .touchUpInside)
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button

        for label in numberLabels {
            view.addSubview(label)
            label.frame = CGRect(x: 125, y: 100 + label.tag * 50, width: 200, height: 40)
        }
    }
    
    @objc private func buttonTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startThread.frame = CGRect(x: view.frame.midX - 125, y: view.frame.midY, width: 250, height: 70)
    }

    @objc private func startThreadAction() {
        // выполнение задач параллельно на глобальной очереди диспетчеризации
        startTasks()
    }

    private func startTasks() {

        // массив замыканий (задач), которые будут выполняться асинхронно
        // на глобальной очереди диспетчеризации
        let tasks: [() -> Int] = [
            { return 10 },
            { return 20 },
            { return 30 },
            { return 40 },
            { return 50 }
        ]

        let group = DispatchGroup() // группировка задач
        
        // ограничиваем кол-во одновременно выполняемых задач
        let semaphore = DispatchSemaphore(value: 1)

        for (index, task) in tasks.enumerated() {
            // добавление задачи (task) в группу
            group.enter()

            // асинхронно в глобальной очереди вызываем выполнение задачи
            DispatchQueue.global().async {

                // гарантируем с помощью семафора, что выполняться может только одна задача
                semaphore.wait()

                let result = task()
                
                // асинхронно отображаем в UI результат выполнения задачи
                DispatchQueue.main.async {
                    self.numberLabels[index].text = "\(result)"
                    print("Задержка окончена")
                }

                Thread.sleep(forTimeInterval: 2) // Задержка в 2 секунды

                // освобождаем семафор и даем сигнал, что может выполняться следующая задача
                semaphore.signal()

                // задача завершена -> вызываем leave()
                group.leave()
            }
            
            
        }
        
//        let res = group.wait()
//        if res == .success {
//            // все операции завершены
//        } else if res == .timeout {
//            // истекло время ожидания
//        } else {
//            // ошибка
//        }

        group.notify(queue: .main) {
            print("Все задачи завершены")
        }


    }

}

