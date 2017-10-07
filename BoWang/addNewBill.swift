/*
 This class is to add a new bill
 1. Write all details to a new bill
 2. store it to Azure
 */

import Foundation
import UIKit

protocol ToDoItemDelegate {
    func didSaveItem(_ label: String, _ theCost: String, _ describ: String)
}

class addNewBill: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate {
    
    //Information need to enter
    @IBOutlet weak var labels: UITextField!
    @IBOutlet weak var theCost: UITextField!
    @IBOutlet weak var describ: UITextField!
    
    var delegate : ToDoItemDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.labels.delegate = self
    }
    
    //Cancel what you current type
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.labels.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    //Save the information
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let labels = self.labels.text
        let theCost = self.theCost.text
        let describ = self.describ.text
        
        if (labels?.isEmpty)! || (theCost?.isEmpty)! || (describ?.isEmpty)! {
            displayMyAlertMessage(userMessage: "all filed are required")
            return
        }
        
        //check if password match
        if (Int(theCost!) == nil) {
            displayMyAlertMessage(userMessage: "The cost should be number")
            return
        }
            
        else{
            saveItem()
            self.labels.resignFirstResponder()
            
            //display alert message with confimation
            let myAlert = UIAlertController(title:"Saved", message: "you add the bill successfully, thank you", preferredStyle: UIAlertControllerStyle.alert)
            self.present( myAlert, animated: true, completion: nil)
            
            //???
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                myAlert.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    
    // Textfield
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        saveItem()
        
        textField.resignFirstResponder()
        return true
    }
    
    //Display an alert
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }

    //hide keyboard when user touches outside keybar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //save information
    func saveItem()
    {
        if let theCost = self.theCost.text,
            let labels = self.labels.text,
            let describ = self.describ.text
        {
            self.delegate?.didSaveItem(labels,theCost,describ)   
        }
    }
}
