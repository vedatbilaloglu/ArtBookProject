//
//  detailsVC.swift
//  ArtBookProject
//
//  Created by Vedat Bilaloğlu on 25.01.2020.
//  Copyright © 2020 Vedat Bilaloglu. All rights reserved.
//

import UIKit
import CoreData
class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenPainting = ""
    var choosenPaintingId : UUID?
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){ // Because year Int value
            newPainting.setValue(year, forKey: "year")
        }
        let data = imageView.image?.jpegData(compressionQuality: 0.5) // Resize Image
        newPainting.setValue(data, forKey: "image")
        newPainting.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("successed")
        }catch{
            print("not successed, error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if choosenPainting != "" {
            // Core Data
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = choosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            }catch{
                print("error")
            }
            
        }else {
            
            saveButton.isHidden = false 
            saveButton.isEnabled = false
            
        }
        
        // Recognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true // After the photo selected, the save button will take action
        self.dismiss(animated: true, completion: nil)
    }

}
