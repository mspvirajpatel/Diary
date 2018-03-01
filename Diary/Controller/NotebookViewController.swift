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
    
    var blockOperations: [BlockOperation] = []
    
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
        for notebook in notebooks {
            print("notebooks id: \(notebook.id!), name: \(notebook.name!), content:\(notebook.comment!)")
        }
        
        collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }) { (true) in
            self.blockOperations.removeAll()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                print("Insert Object: \(newIndexPath)")
                blockOperations.append(BlockOperation(block: {
                    self.collectionView.insertItems(at: [newIndexPath])
                }))
            }
        case .delete:
            if let indexPath = indexPath {
                print("Delete Object: \(indexPath)")
                blockOperations.append(BlockOperation(block: {
                    self.collectionView.deleteItems(at: [indexPath])
                }))
            }
        case .update:
            if let indexPath = indexPath {
                print("Update Object: \(indexPath)")
                blockOperations.append(BlockOperation(block: {
                    self.collectionView.reloadItems(at: [indexPath])
                }))
            }
        default:
            collectionView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            notebooks = fetchedObjects as! [NotebookMO]
        }
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
                let editOptionMenu = UIAlertController(title: nil, message: "choose the item to edit", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                editOptionMenu.addAction(cancelAction)
                
                let editName = UIAlertAction(title: "Title", style: .default, handler: { (action:UIAlertAction!) in
                    let editNameMessage = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
                    editNameMessage.addTextField(configurationHandler: { (textField:UITextField!) in
                        textField.text = self.notebooks[indexPath.row].name ?? ""
                    })
                    editNameMessage.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) in
                        //save name
                    }))
                    editNameMessage.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(editNameMessage, animated: true, completion: nil)
                })
                editOptionMenu.addAction(editName)
                
                let editComment = UIAlertAction(title: "Comment", style: .default, handler: { (action:UIAlertAction!) in
                    let editCommentMessage = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
                    editCommentMessage.addTextField(configurationHandler: { (textField:UITextField!) in
                        textField.text = self.notebooks[indexPath.row].comment ?? ""
                    })
                    editCommentMessage.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) in
                        //save comment
                    }))
                    editCommentMessage.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(editCommentMessage, animated: true, completion: nil)
                })
                editOptionMenu.addAction(editComment)
                
                let editImage = UIAlertAction(title: "Image", style: .default, handler: { (action:UIAlertAction!) in
                    let photoSourceRequestController = UIAlertController(title: "", message: "请选择照片来源", preferredStyle: .actionSheet)
                    let cameraAction = UIAlertAction(title: "照相", style: .default, handler: { (action) in
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            let imagePicker = UIImagePickerController()
                            imagePicker.delegate = self
                            imagePicker.allowsEditing = false
                            imagePicker.sourceType = .camera
                            
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    })
                    
                    let photoLibraryAction = UIAlertAction(title: "相册", style: .default, handler: { (action) in
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            let imagePicker = UIImagePickerController()
                            imagePicker.delegate = self
                            imagePicker.allowsEditing = false
                            imagePicker.sourceType = .photoLibrary
                            
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    })
                    
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    
                    photoSourceRequestController.addAction(cameraAction)
                    photoSourceRequestController.addAction(photoLibraryAction)
                    photoSourceRequestController.addAction(cancelAction)
                    
                    present(photoSourceRequestController, animated: true, completion: nil)
                })
                editOptionMenu.addAction(editImage)
                self.present(editOptionMenu, animated: true, completion: nil)
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
                    alertMessage = UIAlertController(title: "Warning", message: "if you really want to delete Notebook \(self.notebooks[indexPath.row].name!), Please tap yes", preferredStyle: .alert)
                    alertMessage.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                            let context = appDelegate.persistentContainer.viewContext
                            let notebookToDelete = self.fetchResultController.object(at: indexPath)
                            context.delete(notebookToDelete)
                            appDelegate.saveContext()
                        }
                        UserDefaults.standard.set(1, forKey: "defaultNoteBookId")
                    }))
                    alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                } else {
                    alertMessage = UIAlertController(title: "Warning", message: "there are \(self.diaries.count) notes in Notebook:\(self.notebooks[indexPath.row].name!). Please delete them first!", preferredStyle: .alert)
                    alertMessage.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                }
                self.present(alertMessage, animated: true, completion: nil)
            })
            optionMenu.addAction(deleteAction)

            present(optionMenu, animated: true, completion: nil)
            
        }
    }
}
