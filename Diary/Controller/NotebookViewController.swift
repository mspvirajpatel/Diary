//
//  NotebookViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/25.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class NotebookViewController: UIViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var backgroundImageView: UIImageView!
    var photoImage = UIImage()
    var selectNotebook = 0
    var notebook: NotebookMO!
    var historyName = ""
    var historyCommet = ""
    var nameTextField: UITextField!
    var commentTextField: UITextField!
    
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type(of: (anObject as! NSObject)) == type(of: NotebookMO()) {
            switch changeType {
            case .insert:
                if let newIndexPath = newIndexPath {
                    blockOperations.append(BlockOperation(block: {
                        self.collectionView.insertItems(at: [newIndexPath])
                    }))
                }
            case .delete:
                if let indexPath = indexPath {
                    blockOperations.append(BlockOperation(block: {
                        self.collectionView.deleteItems(at: [indexPath])
                    }))
                }
            case .update:
                if let indexPath = indexPath {
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
            cell.alphaView.isHidden = true
        } else {
            cell.notebookNameLabel.text = notebooks[indexPath.row].name
            cell.notebookDescriptionLabel.text = notebooks[indexPath.row].comment
            cell.plusImageView.isHidden = true
            cell.notebookNameLabel.isHidden = false
            cell.notebookDescriptionLabel.isHidden = false
            cell.infoButton.isHidden = false
            cell.alphaView.isHidden = false
            if let coverImageName = notebooks[indexPath.row].coverimage, let coverImage = ImageStore(name: coverImageName).loadImage() {
                cell.imageView.image = coverImage
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImage = selectedImage
        }
        
        dismiss(animated: true, completion: {
            // save image to file
            let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + self.randomString(length: 6) + "-image.jpg"
            let imageStore = ImageStore(name: imageName)
            if imageStore.storeImage(image: self.photoImage) {
                //save image to coredata
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    let fetchRequest: NSFetchRequest<NotebookMO> = NotebookMO.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", self.notebooks[self.selectNotebook].id!)
                    do {
                        let results = try context.fetch(fetchRequest)
                        fetchRequest.returnsObjectsAsFaults = false
                        if(results.count > 0 ){
                            results[0].setValue(imageName, forKey: "coverimage")
                            try context.save();
                            print("Saved.....")
                        } else {
                            print("No results to save")
                        }
                    } catch{
                        print("There was an error")
                    }
                }
            } else {
                print("修改图片失败")
            }
        })
    }
}

extension NotebookViewController: NotebookCollectionCellDelegate {
    func didSeletInfoButton(cell: NotebookCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let optionMenu = UIAlertController(title: nil, message: "option", preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
            optionMenu.addAction(cancelAction)
            
            let editAction = UIAlertAction(title: NSLocalizedString("Edit", comment: "Edit"), style: .default, handler: { (action:UIAlertAction!) in
                let editOptionMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose an item to edit", comment: "Choose an item to edit"), preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                editOptionMenu.addAction(cancelAction)
                
                let editName = UIAlertAction(title: NSLocalizedString("Title", comment: "Title"), style: .default, handler: { (action:UIAlertAction!) in
                    let editNameMessage = UIAlertController(title: NSLocalizedString("Edit Name", comment: "Edit Name"), message: nil, preferredStyle: .alert)
                    editNameMessage.addTextField(configurationHandler: { (textField:UITextField!) in
                        textField.text = self.notebooks[indexPath.row].name ?? ""
                        self.nameTextField = textField
                        self.historyName = textField.text ?? ""
                    })
                    editNameMessage.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) in
                        if self.historyName == self.nameTextField.text {
                            return
                        }
                        //save name
                        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                            let context = appDelegate.persistentContainer.viewContext
                            let fetchRequest: NSFetchRequest<NotebookMO> = NotebookMO.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "id == %@", self.notebooks[indexPath.row].id!)
                            do {
                                let results = try context.fetch(fetchRequest)
                                fetchRequest.returnsObjectsAsFaults = false
                                if(results.count > 0 ){
                                    results[0].setValue(self.nameTextField.text, forKey: "name")
                                    try context.save();
                                    print("Saved.....")
                                } else {
                                    print("No results to save")
                                }
                            } catch{
                                print("There was an error")
                            }
                        }
                    }))
                    editNameMessage.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.default, handler: nil))
                    self.present(editNameMessage, animated: true, completion: nil)
                })
                editOptionMenu.addAction(editName)
                
                let editComment = UIAlertAction(title: NSLocalizedString("Comment", comment: "Comment"), style: .default, handler: { (action:UIAlertAction!) in
                    let editCommentMessage = UIAlertController(title: NSLocalizedString("Edit Comment", comment: "Edit Comment"), message: nil, preferredStyle: .alert)
                    editCommentMessage.addTextField(configurationHandler: { (textField:UITextField!) in
                        textField.text = self.notebooks[indexPath.row].comment ?? ""
                        self.commentTextField = textField
                        self.historyCommet = textField.text ?? ""
                        
                    })
                    editCommentMessage.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: UIAlertActionStyle.default, handler: { (action:UIAlertAction!) in
                        if self.historyCommet == self.commentTextField.text {
                            return
                        }
                        //save comment
                        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                            let context = appDelegate.persistentContainer.viewContext
                            let fetchRequest: NSFetchRequest<NotebookMO> = NotebookMO.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "id == %@", self.notebooks[indexPath.row].id!)
                            do {
                                let results = try context.fetch(fetchRequest)
                                fetchRequest.returnsObjectsAsFaults = false
                                if(results.count > 0 ){
                                    results[0].setValue(self.commentTextField.text, forKey: "comment")
                                    try context.save();
                                    print("Saved.....")
                                } else {
                                    print("No results to save")
                                }
                            } catch{
                                print("There was an error")
                            }
                        }
                    }))
                    editCommentMessage.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(editCommentMessage, animated: true, completion: nil)
                })
                editOptionMenu.addAction(editComment)
                
                let editImage = UIAlertAction(title: NSLocalizedString("Cover Image", comment: "Cover Image"), style: .default, handler: { (action:UIAlertAction!) in
                    self.selectNotebook = indexPath.row
                    let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Please select the photo source", comment: "Please select the photo source"), preferredStyle: .actionSheet)
                    let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler: { (action) in
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            let imagePicker = UIImagePickerController()
                            imagePicker.delegate = self
                            imagePicker.allowsEditing = false
                            imagePicker.sourceType = .camera
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    })
                    
                    let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photos", comment: "Photos"), style: .default, handler: { (action) in
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            let imagePicker = UIImagePickerController()
                            imagePicker.delegate = self
                            imagePicker.allowsEditing = false
                            imagePicker.sourceType = .photoLibrary
                            
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    })
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                    
                    photoSourceRequestController.addAction(cameraAction)
                    photoSourceRequestController.addAction(photoLibraryAction)
                    photoSourceRequestController.addAction(cancelAction)
                    
//                    if let popoverController = photoSourceRequestController.popoverPresentationController {
//                        popoverController.sourceView = self.backgroundImageView
//                        popoverController.sourceRect = self.backgroundImageView.bounds
//                    }
                    
                    self.present(photoSourceRequestController, animated: true, completion: nil)
                })
                editOptionMenu.addAction(editImage)
                self.present(editOptionMenu, animated: true, completion: nil)
            })
            optionMenu.addAction(editAction)

            if self.notebooks[indexPath.row].id! != "1" {
                let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive, handler: { (action:UIAlertAction!) in
                    
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
                        alertMessage = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: (NSLocalizedString("Are really want to delete Notebook:", comment: "Are really want to delete Notebook:") + self.notebooks[indexPath.row].name!), preferredStyle: .alert)
                        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { (alertAction) in
                            // delete image from filemanager
                            if let coverImageName = self.notebooks[indexPath.row].coverimage {
                                if ImageStore(name: coverImageName).deleteImage() {
                                    print("删除照片文件成功")
                                } else {
                                    print("删除照片文件失败")
                                }
                            }
                            
                            // delete notebook from coredata
                            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                                let context = appDelegate.persistentContainer.viewContext
                                let notebookToDelete = self.fetchResultController.object(at: indexPath)
                                context.delete(notebookToDelete)
                                print("成功删除笔记本")
                                appDelegate.saveContext()
                            }
                            UserDefaults.standard.set(1, forKey: "defaultNoteBookId")
                        }))
                        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
                    } else {
                        let warningMessage = NSLocalizedString("There are", comment: "There are") + String(self.diaries.count) + NSLocalizedString("notes in Notebook:", comment: "notes in Notebook:") + self.notebooks[indexPath.row].name! + NSLocalizedString(". Please delete them first!", comment: ". Please delete them first!")
                        alertMessage = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: warningMessage, preferredStyle: .alert)
                        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .default, handler: nil))
                    }
                    self.present(alertMessage, animated: true, completion: nil)
                })
                optionMenu.addAction(deleteAction)
            }

            present(optionMenu, animated: true, completion: nil)
            
        }
    }
}
