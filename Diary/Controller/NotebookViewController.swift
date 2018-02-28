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
    var diaries:[DiaryMO] = []
    var fetchResultController: NSFetchedResultsController<NotebookMO>!
    var fetchDiaryResultController: NSFetchedResultsController<DiaryMO>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: "cloud")
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        // Reduce the height of the collection view for 4-inch devices.
        if UIScreen.main.bounds.size.height == 568.0 {
            let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: 250.0, height: 330.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        collectionView.reloadData()
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
            cell.notebookDescriptionLabel.isHidden = true
            cell.infoButton.isHidden = true
            cell.notesLabel.isHidden = true
            cell.alphaView.isHidden = true
        } else {
            cell.notebookNameLabel.text = notebooks[indexPath.row].name
            cell.notebookDescriptionLabel.text = notebooks[indexPath.row].comment
            cell.notesLabel.text = ""
            cell.plusImageView.isHidden = true
            cell.notebookNameLabel.isHidden = false
            cell.notebookDescriptionLabel.isHidden = false
            cell.infoButton.isHidden = false
            cell.notesLabel.isHidden = false
            cell.alphaView.isHidden = false
            if let coverImageData = notebooks[indexPath.row].coverimage {
                cell.imageView.image = UIImage(data: coverImageData)
            } else {
                cell.imageView.image = UIImage()
            }
        }
        
        cell.layer.cornerRadius = 4.0
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == notebooks.count {
            if let newNotebookNavigationController = storyboard?.instantiateViewController(withIdentifier: "NewNotebookNavigationController") as? UINavigationController {
                present(newNotebookNavigationController, animated: true, completion: nil)
            }
        } else {
            UserDefaults.standard.set(notebooks[indexPath.row].id, forKey: "defaultNoteBookId")
            dismiss(animated: true, completion: nil)
        }
    }
}

extension NotebookViewController: NotebookCollectionCellDelegate {
    func didSeletInfoButton(cell: NotebookCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            print(indexPath.row)
            let optionMenu = UIAlertController(title: nil, message: "option", preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            optionMenu.addAction(cancelAction)
            
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action:UIAlertAction!) in
                print(indexPath.row)
            })
            optionMenu.addAction(editAction)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction!) in
                // Diary Counts
                // Fetch data from data store - Diary
                let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                fetchRequest.predicate = NSPredicate(format: "notebookid == %@", self.notebooks[indexPath.row].id!)
                
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    self.fetchDiaryResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                    self.fetchDiaryResultController.delegate = self
                    
                    do {
                        try self.fetchDiaryResultController.performFetch()
                        if let fetchedObjects = self.fetchDiaryResultController.fetchedObjects {
                            self.diaries = fetchedObjects
                        }
                    } catch {
                        print(error)
                    }
                }
                var alertMessage = UIAlertController()
                if self.diaries.count == 0 {
                    alertMessage = UIAlertController(title: "Warning", message: "if you really want to delete No.\(indexPath.row) item, Please tap yes", preferredStyle: .alert)
                } else {
                    alertMessage = UIAlertController(title: "Warning", message: "there are \(self.diaries.count) in Notebook:\(self.notebooks[indexPath.row].name!). Please ensure delete them all.", preferredStyle: .alert)
                }
                alertMessage.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alertMessage, animated: true, completion: nil)
            })
            optionMenu.addAction(deleteAction)

            present(optionMenu, animated: true, completion: nil)
            
        }
    }
}
