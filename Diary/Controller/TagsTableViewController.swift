//
//  TagsTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/5.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class TagsTableViewController: UITableViewController {
    let tags:[String] = ["日记", "微信", "jQuery", "Linux", "Mac", "PHP", "会议"]
    
    var choosedTags: [String] = []
    var chooseTagsInit: [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagsCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = tags[indexPath.row]
        if chooseTagsInit.count > 0 {
            for chooseTagsInitString in chooseTagsInit {
                if chooseTagsInitString == tags[indexPath.row] {
                    cell.accessoryType = .checkmark
                    choosedTags.append(chooseTagsInitString)
                }
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.none {
            if self.choosedTags.count >= 3 {
                let alertController = UIAlertController(title: nil, message: "标签不能超过三条", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
            } else {
                self.choosedTags.append(tags[indexPath.row])
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        } else {
            self.choosedTags.remove(at: self.choosedTags.index(of: tags[indexPath.row])!)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }

}
