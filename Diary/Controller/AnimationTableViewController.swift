//
//  AnimationTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/29.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class AnimationTableViewController: UITableViewController {
    let MAX_ANGLE: Float = 180.0
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
        UserDefaults.standard.set(Int(round(sender.value * MAX_ANGLE)), forKey: "tableView3DAngle")
        angleLabel.text = String(Int(round(sender.value * MAX_ANGLE))) + "˚"
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
        angleSlider.value = Float(UserDefaults.standard.integer(forKey: "tableView3DAngle")) / MAX_ANGLE
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

}
