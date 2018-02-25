//
//  NoteBook.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/25.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import Foundation

class NoteBook {
    var name: String
    var author: String
    var coverImage: String
    var description: String
    
    init(name: String, author: String, coverImage: String, description: String) {
        self.name = name
        self.author = author
        self.description = description
        self.coverImage = coverImage
    }
}
