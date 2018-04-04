//
//  NewNotebookTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/25.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class NewNotebookTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet var nameTextField: RoundedTextFIeld!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var photoImageView: UIImageView!
    var descriptionPlaceholder: String = ""
    
    var notebook: NotebookMO!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let maxNoteBookId = UserDefaults.standard.integer(forKey: "maxNoteBookId") + 1
            notebook = NotebookMO(context: appDelegate.persistentContainer.viewContext)
            notebook.id = String(maxNoteBookId)
            notebook.name = nameTextField.text
            if descriptionTextView.text == NSLocalizedString("write the description of notebook...", comment: "write the description of notebook...") {
                notebook.comment = ""
            } else {
                notebook.comment = descriptionTextView.text
            }
            let currentDate = Date.init()
            notebook.create = currentDate
            notebook.update = currentDate
            
            if let notebookCoverImage = photoImageView.image {
                let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + randomString(length: 6) + "-image.jpg"
                let imageStore = ImageStore(name: imageName)
                if imageStore.storeImage(image: notebookCoverImage) {
                    notebook.coverimage = imageName
                }
            }
            UserDefaults.standard.set(maxNoteBookId, forKey: "maxNoteBookId")
            print("Saving data to context")
            appDelegate.saveContext()
        }
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        tableView.separatorStyle = .none
        descriptionTextView.delegate = self
        descriptionPlaceholder = NSLocalizedString("write the description of notebook...", comment: "write the description of notebook...")
        descriptionTextView.text = descriptionPlaceholder
        descriptionTextView.textColor = .lightGray
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == descriptionPlaceholder)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == ""
        {
            textView.text = descriptionPlaceholder
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleToFill
            photoImageView.clipsToBounds = true
        }
        
        let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .trailing, relatedBy: .equal, toItem: photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
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
            
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                popoverController.sourceView = self.photoImageView
                popoverController.sourceRect = self.photoImageView.bounds
            }
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
}
