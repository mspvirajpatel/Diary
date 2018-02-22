//
//  UINavigationController+Ext.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

extension UINavigationController {

    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
