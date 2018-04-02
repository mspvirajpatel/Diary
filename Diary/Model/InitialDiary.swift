//
//  InitialDiary.swift
//  Diary
//
//  Created by 牛苒 on 2018/4/2.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import Foundation

class InitialDiary {
    var title: String
    var content: String
    var image: String
    var tag: String
    var weather: String
    
    init(title: String, content: String, image: String, tag: String, weather: String) {
        self.title = title
        self.content = content
        self.image = image
        self.tag = tag
        self.weather = weather
    }
}
