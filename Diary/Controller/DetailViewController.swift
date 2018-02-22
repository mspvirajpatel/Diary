//
//  DetailViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var diary = Diary()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fullImageView: UIImageView!
    @IBOutlet var tagLabel: UILabel! {
        didSet {
            tagLabel.layer.cornerRadius = 5.0
            tagLabel.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = diary.title
        tagLabel.text = diary.tag[0]
        fullImageView.image = UIImage(named: diary.image[0])
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.hidesBarsOnSwipe = false
        
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailAuthorTableViewCell.self), for: indexPath) as! DetailAuthorTableViewCell
            cell.avatarImageView.image = UIImage(named: diary.avatar)
            cell.authorLabel.text = diary.author
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailWeatherAndLocationTableViewCell.self), for: indexPath) as! DetailWeatherAndLocationTableViewCell
            cell.weatherImageView.image = UIImage(named: diary.weather)
            cell.weatherLabel.text = diary.weather
            cell.locationIconImageView.image = UIImage(named: "map")
            cell.locationButton.setTitle(diary.location, for: UIControlState.normal)
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailTextTableViewCell.self), for: indexPath) as! DetailTextTableViewCell
            cell.contentLabel.text = diary.content
            
            return cell
        default:
            fatalError("Failed tor instantiate the table view cell for detail view controller")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.diary = diary
        }
    }

}
