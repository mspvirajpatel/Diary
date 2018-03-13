//
//  DiscoverTableViewCell.swift
//  Diary
//
//  Created by 牛苒 on 12/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

    @IBOutlet var fullImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var updateDateLabel: UILabel!
    @IBOutlet var deviceNameLabel: UILabel! {
        didSet {
            deviceNameLabel.layer.cornerRadius = 5.0
            deviceNameLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet var tagLabel: UILabel! {
        didSet {
            tagLabel.layer.cornerRadius = 5.0
            tagLabel.layer.masksToBounds = true
        }
    }

}
