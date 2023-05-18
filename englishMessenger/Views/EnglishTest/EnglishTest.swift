//
//  EnglishTest.swift
//  englishMessenger
//
//  Created by Данила on 24.04.2023.
//

import UIKit


class EnglishTest: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var arrayList = ["item 1", "item 2", "item 3", "item 4", "item 5", "item 6", "item 7"]
    
    
    override func viewDidLoad() {
        self.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell") as! EnglishTestCell
        cell.answerLabel.text = self.arrayList[indexPath.row]
        // let isRowChecked = row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    

}


class EnglishTestCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var checkBoxButton: CheckBoxButton!
    
}
