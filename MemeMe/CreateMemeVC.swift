//
//  ViewController.swift
//  MemeMe
//
//  Created by José Naves Moura Neto on 25/10/18.
//  Copyright © 2018 José Naves Moura Neto. All rights reserved.
//

import UIKit

class CreateMemeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    @IBOutlet weak var buttonCamera: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topMemeText: UITextField!
    @IBOutlet weak var bottomMemeText: UITextField!
    @IBOutlet weak var buttonShare: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var activeTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // subcribe to keyboard notifications, to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topMemeText.delegate = self
        bottomMemeText.delegate = self
        
        // check if there's a camera available on device
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        resetUI()
    }
    
    func resetUI() {
        configureTextProperties(topMemeText, "TOP")
        configureTextProperties(bottomMemeText, "BOTTOM")
        buttonShare.isEnabled = false
        imageView.image = nil
    }
    
    func configureTextProperties(_ textField: UITextField, _ defaulText: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let memeTextAttributes:[NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -1.00,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        textField.defaultTextAttributes = memeTextAttributes
        
        // make the background transparent
        textField.backgroundColor = UIColor.clear
        
        textField.text = defaulText
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
    
    @IBAction func cancel() {
        // reset ui
        resetUI()
    }
    
    @IBAction func shareMeme() {
        // Create the meme
        let meme = Meme(topText: topMemeText.text!,
                        bottomText: bottomMemeText.text!,
                        originalImage: imageView.image!,
                        memedImage: generateMemedImage())
        
        // show the Activity Share
        let activityViewController = UIActivityViewController(
            activityItems: [meme.memedImage],
            applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        present(activityViewController, animated: true, completion: nil)
        
        // access the completion handler
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                //  save on gallery
                self.saveMemeInGallery(selectedImage: meme.memedImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        buttonShare.isEnabled = true
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if activeTextField == bottomMemeText {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue // of CGRect
        return keyboardSize.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Assign the newly active text field to your activeTextField variable
    // This is important to only shift the view when we are editing the bottom text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        textField.text = ""
    }
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        setBarsHidden(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        setBarsHidden(false)
        
        return memedImage
    }
    
    func setBarsHidden(_ isHidden: Bool) {
        navigationController?.setNavigationBarHidden(isHidden, animated: false)
        navigationBar.isHidden = isHidden
        toolbar.isHidden = isHidden
    }
    
    func saveMemeInGallery(selectedImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(imageSavedCallback(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // Add image to Library
    @objc func imageSavedCallback(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
