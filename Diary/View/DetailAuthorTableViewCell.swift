//
//  DetailAuthorTableViewCell.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class DetailAuthorTableViewCell: UITableViewCell {
    
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 30.0
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
