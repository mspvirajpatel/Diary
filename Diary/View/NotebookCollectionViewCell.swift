//
//  NotebookCollectionViewCell.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/25.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

protocol NotebookCollectionCellDelegate {
    func didSeletInfoButton(cell: NotebookCollectionViewCell)
}

class NotebookCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var notebookNameLabel: UILabel! {
        didSet {
            notebookNameLabel.layer.cornerRadius = 10.0
            notebookNameLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet var notebookDescriptionLabel:UILabel!
    @IBOutlet var plusImageView: UIImageView!
    
    var delegate: NotebookCollectionCellDelegate?
    @IBOutlet var alphaView: UIView!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var infoButton: UIButton! {
        didSet {
            infoButton.tintColor = UIColor.white
        }
    }
    @IBAction func infoButtonTapped(sender: AnyObject) {
        delegate?.didSeletInfoButton(cell: self)
    }
    
}
