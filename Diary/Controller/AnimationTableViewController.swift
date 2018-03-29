//
//  AnimationTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/29.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class AnimationTableViewController: UITableViewController {
    
    @IBOutlet weak var animationType: UISegmentedControl!
    
    @IBAction func changeAnimationType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UserDefaults.standard.set(true, forKey: "isOpenRotation")
        } else {
            UserDefaults.standard.set(false, forKey: "isOpenRotation")
        }
        tableView.reloadData()
    }
    
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet weak var tableView3DSwitch: UISwitch!
    
    @IBAction func changeTableView3DSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isOpenTableView3D")
        tableView.reloadData()
    }
    @IBOutlet weak var angleSlider: UISlider!
    
    @IBAction func changeAngleSlider(_ sender: UISlider) {
        UserDefaults.standard.set(Int(round(sender.value * 90)), forKey: "tableView3DAngle")
        angleLabel.text = String(Int(round(sender.value * 90))) + "˚"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isOpenRotation") {
            animationType.selectedSegmentIndex = 0
        } else {
            animationType.selectedSegmentIndex = 1
        }
        tableView3DSwitch.isOn = UserDefaults.standard.bool(forKey: "isOpenTableView3D")
        angleLabel.text = String(UserDefaults.standard.integer(forKey: "tableView3DAngle")) + "˚"
        angleSlider.value = Float(UserDefaults.standard.integer(forKey: "tableView3DAngle")) / 90.0
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView3DSwitch.isOn {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            if animationType.selectedSegmentIndex == 0 {
                return 2
            } else {
                return 1
            }
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
