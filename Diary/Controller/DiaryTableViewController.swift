//
//  DiaryTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/21.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class DiaryTableViewController: UITableViewController {
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    var diarys:[Diary] = [
        Diary(title: "Cafe Deadend", content: "This is content.", author: "jack", tag: ["Coffee & Tea Shop"], location: "郑州市二七区", image: ["cafedeadend"], avatar: "avatar-afro-black-man-beard", weather: "sunny", review: 1),
        Diary(title: "Homei", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "tim", tag: ["Cafe"], location: "郑州市二七区", image: ["homei"], avatar: "avatar-albert-einstein-hair", weather: "foggy", review: 12),
        Diary(title: "Teakha", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "fab", tag: ["Tea House"], location: "郑州市二七区", image: ["teakha"], avatar: "avatar-asian-business-woman", weather: "lighting", review: 12),
        Diary(title: "Cafe loisl", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "tom", tag: ["Austrian / Causual Drink"], location: "郑州市二七区", image: ["cafeloisl"], avatar: "avatar-beard-shades-cool", weather: "overcast", review: 123),
        Diary(title: "Petite Oyster", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "ben", tag: ["French"], location: "郑州市二七区", image: ["petiteoyster"], avatar: "avatar-bernie-sanders-old-man", weather: "rain", review: 12300),
        Diary(title: "For Kee Diary", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "ran", tag: ["Bakery"], location: "郑州市二七区", image: ["forkeerestaurant"], avatar: "avatar-black-african-american-woman", weather: "sand storm", review: 1230),
        Diary(title: "Po's Atelier", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "tee", tag: ["Bakery"], location: "郑州市二七区", image: ["posatelier"], avatar: "avatar-black-man-beard-glasses", weather: "snow", review: 123),
        Diary(title: "Bourke Street Backery", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "bika", tag: ["Chocolate"], location: "郑州市二七区", image: ["bourkestreetbakery"], avatar: "avatar-black-man-beard", weather: "cloudy", review: 123),
        Diary(title: "Haigh's Chocolate", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "coo", tag: ["Cafe"], location: "郑州市二七区", image: ["haighschocolate"], avatar: "avatar-black-man-clean-shaven", weather: "tornado", review: 123),
        Diary(title: "Palomino Espresso", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "tta", tag: ["American / Seafood"], location: "郑州市二七区", image: ["palominoespresso"], avatar: "avatar-black-man-professor", weather: "sunny", review: 123),
        Diary(title: "Upstate", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "q", tag: ["American"], location: "郑州市二七区", image: ["upstate"], avatar: "avatar-black-woman-young", weather: "sunny", review: 123),
        Diary(title: "Traif", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "qinfeng", tag: ["American"], location: "郑州市二七区", image: ["traif"], avatar: "avatar-hillary-clinton-woman", weather: "sunny", review: 123),
        Diary(title: "Graham Avenue Meats", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "aa", tag: ["Breakfast & Brunch"], location: "郑州市二七区", image: ["grahamavenuemeats"], avatar: "avatar-hipster-beard-flannel", weather: "sunny", review: 123),
        Diary(title: "Waffle & Wolf", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "ee", tag: ["Coffee & Tea"], location: "郑州市二七区", image: ["wafflewolf"], avatar: "avatar-indian-bengali-woman", weather: "sunny", review: 123),
        Diary(title: "Five Leaves", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "tt", tag: ["Coffee & Tea"], location: "郑州市二七区", image: ["fiveleaves"], avatar: "avatar-indian-man-beard", weather: "sunny", review: 123),
        Diary(title: "Cafe Lore", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "zxc", tag: ["Latin American"], location: "郑州市二七区", image: ["cafelore"], avatar: "avatar-indian-man-clean-shaven", weather: "sunny", review: 123),
        Diary(title: "Confessional", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "xx", tag: ["Spanish"], location: "郑州市二七区", image: ["confessional"], avatar: "avatar-man-stubble", weather: "sunny", review: 123),
        Diary(title: "Barrafina", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "sf", tag: ["Spanish"], location: "郑州市二七区", image: ["barrafina"], avatar: "avatar-modern-indian-woman", weather: "sunny", review: 123),
        Diary(title: "Donostia", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "fs", tag: ["Spanish"], location: "郑州市二七区", image: ["donostia"], avatar: "avatar-mohawk-punk-man", weather: "sunny", review: 123),
        Diary(title: "Royal Oak", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "asc", tag: ["British"], location: "郑州市二七区", image: ["royaloak"], avatar: "avatar-professor-white-man", weather: "sunny", review: 123),
        Diary(title: "CASK Pub and Kitchen", content: "This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content, This is content.", author: "cc", tag: ["Thai"], location: "郑州市二七区", image: ["caskpubkitchen"], avatar: "avatar-woman-bob-girl", weather: "sunny", review: 123)
        ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return diarys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryTableViewCell

        // Configure the cell...
        cell.titleLabel.text = diarys[indexPath.row].title
//        cell.contentLabel.text = diarys[indexPath.row].content
        cell.thumbnailImageView.image = UIImage(named: diarys[indexPath.row].image[0])
        cell.authorLabel.text = diarys[indexPath.row].author
        cell.reviewLabel.text = String(diarys[indexPath.row].review) + "评论"

        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailViewController
                destinationController.diary = diarys[indexPath.row]
            }
        }
    }
}
