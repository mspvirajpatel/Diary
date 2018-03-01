//
//  File.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/28.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import Foundation

struct UserLocation: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    var course: Double
    var speed: Double
    var countryCode: String
    var country: String
    var state: String
    var city: String
    var subLocality: String
    var street: String
}
