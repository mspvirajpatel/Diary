//
//  NotebookViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/25.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class NotebookViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBAction func closeToNotebook(segue: UIStoryboardSegue) {
        
    }
    
    var notebooks:[NotebookMO] = []
    var fetchResultController: NSFetchedResultsController<NotebookMO>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: "cloud")
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        collectionView.backgroundColor = UIColor.clear
        
        // Reduce the height of the collection view for 4-inch devices.
        if UIScreen.main.bounds.size.height == 568.0 {
            let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: 250.0, height: 330.0)
        }

        // Do any additional setup after loading the view.
        let fetchRequest: NSFetchRequest<NotebookMO> = NotebookMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    notebooks = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension NotebookViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notebooks.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotebookCell", for: indexPath) as! NotebookCollectionViewCell
        
        // Configure the cell
        if indexPath.row == notebooks.count {
            cell.notebookNameLabel.isHidden = true
            cell.imageView.image = UIImage()
            cell.imageView.backgroundColor = UIColor.lightGray
            cell.plusImageView.isHidden = false
        } else {
            cell.notebookNameLabel.text = notebooks[indexPath.row].name
            cell.plusImageView.isHidden = true
            if let coverImageData = notebooks[indexPath.row].coverimage {
                cell.imageView.image = UIImage(data: coverImageData)
            } else {
                cell.imageView.image = UIImage()
            }
        }
        
        cell.layer.cornerRadius = 4.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == notebooks.count {
            // add notebook
        } else {
            // choose a notebook and return
        }
    }
}
