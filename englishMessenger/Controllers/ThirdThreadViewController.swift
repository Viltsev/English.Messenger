//
//  ThirdThreadViewController.swift
//  englishMessenger
//
//  Created by Данила on 13.05.2023.
//

import UIKit

class ThirdThreadViewController: UIViewController {

    private var timer: DispatchSourceTimer?
    private var count = 1
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        
        label.frame = CGRect(x: 50, y: 200, width: view.frame.width - 100, height: 50)
        startTimer()
    }
    
    @objc private func buttonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func startTimer() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.label.text = "\(self.count)"
                self.count += 1
            }
        }
        timer?.resume()
    }

}
