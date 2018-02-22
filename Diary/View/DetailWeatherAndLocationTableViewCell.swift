//
//  DetailWeatherAndLocationTableViewCell.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class DetailWeatherAndLocationTableViewCell: UITableViewCell {
    
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var locationIconImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
