//
//  Image.swift
//  Diary
//
//  Created by 牛苒 on 15/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import Foundation
import UIKit

class ImageStore {
    var name: String
//    var imageArray: [String]
    
    
    init(name: String) {
        self.name = name
//        self.imageArray = name.components(separatedBy: ",")
    }
    
    func loadImage() -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        
        let fileName = self.name
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let image = UIImage(contentsOfFile: fileURL.path) {
            return image
        } else {
            return nil
        }
    }
    
    func storeImage(image: UIImage) -> Bool {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        
        let fileName = self.name
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = UIImageJPEGRepresentation(image, 1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("image saved")
                return true
            } catch {
                print("error saving image:\(error.localizedDescription)")
                return false
            }
        } else {
            return false
        }
    }
    
    func deleteImage() -> Bool {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        
        let fileName = self.name
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("image removed!")
            return true
        } catch {
            print("error remove image:\(error.localizedDescription)")
            return false
        }
    }

}
