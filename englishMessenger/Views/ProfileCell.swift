//
//  ProfileCell.swift
//  englishMessenger
//
//  Created by Данила on 19.05.2023.
//

import UIKit


struct Icons {
    static let test = UIImage(named: "testImage")!
    static let dictionary = UIImage(named: "dictionaryImage")!
    static let train = UIImage(named: "trainImage")!
}

struct ProfileCellStruct {
    var icon: UIImage
    var title: String
}

class ProfileCell: UITableViewCell {
    
    
    var profileImageView = UIImageView()
    var titleLabel = UILabel()
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(titleLabel)
        
        configureImageView()
        configureTitleLabel()
        setImageConstraints()
        setTitleLabelConstraints()
        
        backgroundColor = UIColor(named: "profileBackground")
        // backgroundColor = UIColor.systemPurple
        layer.cornerRadius = 20 // Радиус закругления ячейки
        layer.masksToBounds = true // Обрезает содержимое ячейки по границам закругления
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(cell: ProfileCellStruct) {
        profileImageView.image = cell.icon
        titleLabel.text = cell.title
        titleLabel.textColor = UIColor(named: "darkPurple")
        titleLabel.font = UIFont(name: "Optima", size: 18)
    }
    
    func configureImageView() {
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
    }
    
    func configureTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setImageConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 16/16).isActive = true
    }
    
    func setTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
    }
}
