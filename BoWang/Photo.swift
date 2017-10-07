/*
 The final app doesn't have this class, however, it's to take a photo or hoose from the photolibrary and save it to Azure as String
 */

import UIKit
import AssetsLibrary




class Photo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBAction func addPhoto(_ sender: UIButton) {
        
        showActionSheet()
    }
    
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "PHOTO SOURCE", message: nil, preferredStyle: .actionSheet)
        
        //photo source - camera
        actionSheet.addAction(UIAlertAction(title: "CAMERA", style: .default, handler: { alertAction in
            self.showImagePickerForSourceType(.camera)
        }))
        
        //photo source - photo library
        actionSheet.addAction(UIAlertAction(title: "PHOTO LIBRARY", style: .default, handler: { alertAction in
            self.showImagePickerForSourceType(.photoLibrary)
        }))
        
        //cancel button
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler:nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showImagePickerForSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        
        DispatchQueue.main.async(execute: {
            let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = true
            imagePickerController.modalPresentationStyle = .currentContext
            imagePickerController.sourceType = sourceType
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        })
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            
            print("media type: \(String(describing: info[UIImagePickerControllerMediaType]))")
            
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6)
        let compreseedJPEGImage = UIImage(data: imageData!)
        let assets : ALAssetsLibrary = ALAssetsLibrary()
        let imgRef : CGImage = compreseedJPEGImage!.cgImage!
        let orientation : ALAssetOrientation = ALAssetOrientation(rawValue: compreseedJPEGImage!.imageOrientation.rawValue)!
        assets.writeImage(toSavedPhotosAlbum: imgRef, orientation: orientation, completionBlock:
            { _,_ in (path:NSURL!, error:NSError!).self
        })
        saveNotice()
    }
    
    func saveNotice() {
        
        let alertController = UIAlertController(title: "Image Saved!", message: "Your picture was succeddful saved.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //hide keyboard when user touches outside keybar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //presses return key to dismiss keyboard
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


