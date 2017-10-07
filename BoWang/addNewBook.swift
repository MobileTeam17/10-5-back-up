/*
 This class is to add a new accountbook
*/

import Foundation
import UIKit

protocol ToDoItemDelegate3 {
    func didSaveItem(_ newBookName: String)
}

class addNewBook: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate {
    
    var dicClient = [String:Any]()
    var list = NSMutableArray()

    @IBOutlet weak var newBookName: UITextField!
    
    var bookId = ""
    var bool = "false"
    var delegate : ToDoItemDelegate3?
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "AccountBook")
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    self.list.add("\(item["bookName"]!)")
                }
            }
        }

        
        
    }
    
    //cancel
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.newBookName.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func addPressed(_ sender: UIButton) {
        let newBookName = self.newBookName.text
        
        if (newBookName?.isEmpty)!{
            displayMyAlertMessage(userMessage: "all filed are required")
            return
        }

        if list.contains(newBookName) {
            self.displayMyAlertMessage(userMessage: "this name has already been used ")
            return
        }

        self.saveItem()
        self.newBookName.resignFirstResponder()

        //display alert message with confimation
        let myAlert = UIAlertController(title:"successful", message: "you add the book successfully, thank you", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present( myAlert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.navigationController?.popViewController(animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            myAlert.dismiss(animated: true, completion: nil)
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
    
    //display alert
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //save data
    func saveItem()
    {
        var newBookName = self.newBookName.text
        print("the newBookName is : ", newBookName)
        self.delegate?.didSaveItem(newBookName!)
        
    }
}
