//
//  CheckBoxButton.swift
//  englishMessenger
//
//  Created by Данила on 26.04.2023.
//

import Foundation
import UIKit


class CheckBoxButton: UIButton {
    let checkedImage = UIImage(named: "checkbox")!
    let unCheckedImage = UIImage(named: "uncheckbox")!
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(unCheckedImage, for: .normal)
            }
            else {
                self.setImage(checkedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.isUserInteractionEnabled = true
        self.addTarget(self, action: #selector(CheckBoxButton.buttonClicked), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            }
            else {
                isChecked = true
            }
        }
    }
    
}
