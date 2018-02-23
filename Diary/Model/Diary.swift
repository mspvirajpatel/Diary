//
//  Diary.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/21.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import Foundation

class Diary {
    var title: String
    var content: String
    var author: String
    var tag: [String]
    var location: String
    var image: String
    var weather: String
    var review: Int
    
    init(title: String, content: String, author:String, tag: [String], location: String, image: String, weather: String, review: Int) {
        self.title = title
        self.content = content
        self.author = author
        self.tag = tag
        self.location = location
        self.image = image
        self.weather = weather
        self.review = review
    }
    
    convenience init() {
        self.init(title: "", content: "", author: "", tag: [], location: "", image: "", weather: "", review: 0)
    }
}
