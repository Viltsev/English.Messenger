//
//  DescribeImageViewController.swift
//  englishMessenger
//
//  Created by Данила on 03.05.2023.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

var available = false
var condition = pthread_cond_t()
var mutex = pthread_mutex_t()
var imageURL: String?
let databaseThread = Firestore.firestore()
var globalImageData: Data!
var changeString: String!
var globalURL: URL!

class DescribeImageViewController: UIViewController {
    
    // экземпляр класса-потока MyThreadMain
    private var threadClass: MyThreadMain?
    
    // ссылка на БД Firestore
    let database = Firestore.firestore()
    
    // спиннер для загрузки
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: UI-элементы
    public let taskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "System" , size: 20)
        label.text = "Опишите картинку"
        label.textColor = .black
        return label
    }()
    
    public var image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .orange
        image.layer.cornerRadius = 10
        return image
    }()
    
    private let textField: UITextView = {
        let text = UITextView()
        text.font = UIFont.systemFont(ofSize: 18)
        text.layer.borderWidth = 0.5
        text.layer.borderColor = UIColor.black.cgColor
        return text
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Проверка", for: .normal)
        button.backgroundColor = .systemPurple
        button.titleLabel?.font = UIFont(name: "Optima", size: 18)
        button.layer.cornerRadius = 12
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
  
        view.addSubview(taskLabel)
        view.addSubview(image)
        view.addSubview(textField)
        view.addSubview(button)
        
        let button = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(buttonTapped))
        button.tintColor = .systemPink
        navigationItem.leftBarButtonItem = button
        
        // добавляем в кнопке button функцию grammarExplain
        self.button.addTarget(self, action: #selector(grammarExplain), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
        
        // вызов функции получения изображения
        getImage()
        
        // запуск потока MyThreadMain для получения изображения
        // threadClass = MyThreadMain(diffClass: self)
        // threadClass?.start()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        taskLabel.frame = CGRect(x: view.frame.size.width / 2 - 75, y: view.safeAreaInsets.top + 10, width: 150, height: 20)
        image.frame = CGRect(x: view.frame.size.width / 2 - 200, y: taskLabel.bottom + 20, width: 400, height: 300)
        textField.frame = CGRect(x: view.frame.size.width / 2 - 200, y: image.bottom + 20, width: 400, height: 300)
        button.frame = CGRect(x: view.frame.size.width / 2 - 100, y: textField.bottom + 20, width: 200, height: 50)
    }
    
    @objc private func buttonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: функция проверки грамматики введенного текста
    @objc func grammarExplain() {
        UserDefaults.standard.set(textField.text, forKey: "userMessage")
        let vc = GrammarChatViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

}

extension DescribeImageViewController {
    // MARK: функция получения изображения
    func getImage() {
        // ссылка на document в БД Firebase
        let docRef = database.document("describeTraining/images")
        spinner.show(in: view)
        
        let dbqueue = DispatchQueue.global(qos: .utility)
        
        dbqueue.async {
            // чтение данных из БД
            docRef.addSnapshotListener { [weak self] snapshot, error in
                
                // получение данных
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                guard let strongSelf = self else {
                    return
                }
                
                let randomNumberOfImage = Int.random(in: 1..<4)

                // получаем из данных ссылку на картинку
                guard let newImage = data["image\(randomNumberOfImage)"] as? String else {
                        return
                }
                
                // превращение ссылки типа String в URL
                let url = URL(string: newImage)
                
                // создание глобальной очереди с высоким уровнем приоритета
                let queue = DispatchQueue.global(qos: .utility)
                
                // асинхронный вызов очереди
                queue.async {
                    // получение изображения по ссылке
                    let imageData = try! Data(contentsOf: url!)
                    
                    // обновление UI - АСИНХРОННО В ГЛАВНОМ ПОТОКЕ
                    DispatchQueue.main.async {
                        strongSelf.image.image = UIImage(data: imageData)
                        strongSelf.image.layer.cornerRadius = 20
                    }

                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                }

            }
        }
        
    }
}

// MARK: поток, в котором происходит получение изоюражения
class MyThreadMain: Thread {
    weak var diffClass: DescribeImageViewController?

    init(diffClass: DescribeImageViewController) {
        self.diffClass = diffClass
        super.init()
    }

    override func main() {
        
        guard let diffClass = diffClass else {
            return
        }
        
        // ссылка на document в БД Firebase
        let docRef = diffClass.database.document("describeTraining/images")
        
        // чтение данных из БД
        docRef.addSnapshotListener { [weak self] snapshot, error in
            
            // получение данных
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            
            let randomNumberOfImage = Int.random(in: 1..<4)

            // получаем из данных ссылку на картинку
            guard let newImage = data["image\(randomNumberOfImage)"] as? String else {
                    return
            }
            
            // превращение ссылки типа String в URL
            let url = URL(string: newImage)
            
            // создание глобальной очереди с высоким уровнем приоритета
            let queue = DispatchQueue.global(qos: .utility)
            
            // асинхронный вызов очереди
            queue.async {
                // получение изображения по ссылке
                let imageData = try! Data(contentsOf: url!)
                
                // обновление UI - АСИНХРОННО В ГЛАВНОМ ПОТОКЕ
                DispatchQueue.main.async {
                    diffClass.image.image = UIImage(data: imageData)
                    diffClass.image.layer.cornerRadius = 20
                }
            }

        }
    }
    
}


//class myThread: Thread {
//    let example = DescribeImageViewController()
//
//    override func main() {
//        // ссылка на document в БД Firebase
//        let docRef = example.database.document("describeTraining/images")
//
//        // чтение данных из БД
//        docRef.addSnapshotListener { snapshot, error in
//
//            // получение данных
//            guard let data = snapshot?.data(), error == nil else {
//                return
//            }
//
//            let randomNumberOfImage = Int.random(in: 1..<4)
//
//            // получаем из данных ссылку на картинку
//            guard let newImage = data["image\(randomNumberOfImage)"] as? String else {
//                    return
//            }
//
//            // превращение ссылки типа String в URL
//            let url = URL(string: newImage)
//
//            let imageData = try! Data(contentsOf: url!)
//
//            // обновление UI - АСИНХРОННО В ГЛАВНОМ ПОТОКЕ
//            DispatchQueue.main.async {
//                self.example.image.image = UIImage(data: imageData)
//                self.example.image.layer.cornerRadius = 20
//            }
//        }
//
//        // ---
//    }
//}

//class mySecondThread: Thread {
//    let example = DescribeImageViewController()
//
//    override func main() {
//        // получение изображения по ссылке
//
//    }
//}



//class GetImageThread: Thread {
//
//    override init() {
//        pthread_cond_init(&condition, nil)
//        pthread_mutex_init(&mutex, nil)
//    }
//
//    override func main() {
//        getImage()
//    }
//
//    private func getImage() {
//        pthread_mutex_lock(&mutex)
//        print("get image thread start")
//        while (!available) {
//            pthread_cond_wait(&condition, &mutex)
//        }
//
//        // code here
//
//        let url = URL(string: imageURL!)
//        let imageData = try! Data(contentsOf: url!)
//        globalImageData = try? imageData
//
//
//
//        // --------------
//
//        available = false
//        defer {
//            pthread_mutex_unlock(&mutex)
//        }
//        print("get image thread end")
//
//        DispatchQueue.main.async {
//            let mainClass = DescribeImageViewController()
//            mainClass.image.image = UIImage(data: imageData)
//        }
//
//
//    }
//
//}
//
//
//class GetImageURLThread: Thread {
//
//    override init() {
//        pthread_cond_init(&condition, nil)
//        pthread_mutex_init(&mutex, nil)
//    }
//
//    override func main() {
//        getImageURL()
//    }
//
//    private func getImageURL() {
//        pthread_mutex_lock(&mutex)
//        print("get image url thread start")
//
//        // code here
//        let docRef = databaseThread.document("describeTraining/images")
//
//        docRef.addSnapshotListener { [weak self] snapshot, error in
//            guard let data = snapshot?.data(), error == nil else {
//                return
//            }
//
//            let randomNumberOfImage = Int.random(in: 1..<4)
//
//            /// получаем из data ссылку на картинку
//            guard let newImage = data["image\(randomNumberOfImage)"] as? String else {
//                    return
//            }
//
//            imageURL = newImage
//
//            available = true
//            pthread_cond_signal(&condition)
//            defer {
//                pthread_mutex_unlock(&mutex)
//            }
//            print("get image url thread end")
//        }
//    }
//}






