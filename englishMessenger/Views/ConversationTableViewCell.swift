//
//  ConversationTableViewCell.swift
//  englishMessenger
//
//  Created by Данила on 04.03.2023.
//

import UIKit
import SDWebImage

// MARK: класс ячейки таблицы диалогов
// в данном классе находится UI-ячейки таблицы диалогов
class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        // image description here
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private let userNameView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userNameView)
        contentView.addSubview(userMessageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userNameView.frame = CGRect(x: 20,
                                    y: 10,
                                    width: contentView.width - 120,
                                    height: (contentView.height - 20) / 2)
        
        userMessageView.frame = CGRect(x: 20,
                                       y: userNameView.bottom + 10,
                                       width: contentView.width - 120,
                                       height: (contentView.height - 20) / 2)
    }
    
    public func configure(with model: Conversation) {
        self.userMessageView.text = model.latestMessage.text
        self.userNameView.text = model.name
        
        /// show user's pictures
        // let path = "\(model.otherUserEmail)_profile_picture.png"
        
    }
    
    

}
