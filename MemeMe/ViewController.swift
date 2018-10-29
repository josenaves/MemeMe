//
//  ViewController.swift
//  MemeMe
//
//  Created by José Naves Moura Neto on 25/10/18.
//  Copyright © 2018 José Naves Moura Neto. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var buttonCamera: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topMemeText: UITextField!
    @IBOutlet weak var bottomMemeText: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureTextProperties(topMemeText, "TOP")
        configureTextProperties(bottomMemeText, "BOTTOM")
    }
    
    func configureTextProperties(_ textField: UITextField, _ defaulText: String) {
        textField.text = ""
        textField.textAlignment = NSTextAlignment.center
        textField.text = defaulText

        let memeTextAttributes:[NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: 1.00
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User canceled image selection")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("User picked an image")
        dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
    }
    
}

