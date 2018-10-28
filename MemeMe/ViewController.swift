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
    
    override func viewWillAppear(_ animated: Bool) {
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

}

