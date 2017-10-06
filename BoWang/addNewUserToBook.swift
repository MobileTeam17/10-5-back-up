

import Foundation



// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

protocol ToDoItemDelegate2 {
    func didSaveItem(_ theUser: String, _ bookId: String)
}

class addNewUserToBook: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate {
    
    
    var dicClient = [String:Any]()
    var dicClient2 = [String:Any]()
    var dicClient3 = [String:Any]()
    var list = NSMutableArray()
    var list2 = NSMutableArray()
    var list3 = NSMutableArray()
    var list4 = NSMutableArray()
    
    @IBOutlet weak var userName: UITextField!

    
    var bookId = UserDefaults.standard.string(forKey: "selectedBookId")!

    
    var bool = "false"
    var delegate : ToDoItemDelegate2?
    
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "login")
    var itemTable2 = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "book_users")
    

    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    self.list.add("\(item["email"]!)")
                    
                    
                    
                    self.dicClient2["email"] = "\(item["email"]!)"
                    self.dicClient2["password"] = "\(item["password"]!)"
                    self.dicClient3["email"] = "\(item["email"]!)"
                    print("the item is : ", item)
                    if !self.list3.contains(self.dicClient){
                        self.list3.add(self.dicClient2)
                        print("the list3 object is : ", self.dicClient2)
                    }
                    if !self.list4.contains(self.dicClient2){
                        self.list4.add(self.dicClient3)
                    }
                }
    
            }
        }

        
        var str3=""
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    
                    self.itemTable2.read { (result, error) in
                        if let err = error {
                            print("ERROR ", err)
                        } else if let itemsm = result?.items {
                            for itemm in itemsm {
                                if "\(item["email"]!)" == "\(itemm["theUser"]!)"{
                                    self.list2.add("\(itemm["bookId"]!)")
                                    
                                    
                                }
                            }
                            if str3 != "a"{
                                str3 = "a"+"\(item["email"]!)"
                                UserDefaults.standard.set(self.list2, forKey: str3)
                            }
                            self.list2 = NSMutableArray()

                        }
                    }

                }
                
            }
        }
        

    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.userName.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        let userName = self.userName.text

        
        if (userName?.isEmpty)!  {
            
            //display an alert message
            
            displayMyAlertMessage(userMessage: "all filed are required")
            return
        }
        
        
        if !list.contains(userName) {
            self.displayMyAlertMessage(userMessage: "the user name does not exist")
            return
            
        }
        
        var aa = NSMutableArray()
        
        var strr = ""

        strr = userName!


        var str = "a"+strr
        
        var dicClient = UserDefaults.standard.array(forKey: str)
        
        aa = dicClient as! NSMutableArray
        


        
        if (userName == "" &&
            UserDefaults.standard.array(forKey: str) != nil){
            
            aa = UserDefaults.standard.array(forKey: str) as! NSMutableArray
        }


        let bookId = UserDefaults.standard.string(forKey: UserDefaults.standard.string(forKey: "userRegistEmail")!)!

        if aa.contains(bookId) {
            self.displayMyAlertMessage(userMessage: "the user is already includued in the book")
            return
        }
        
        


        
        UserDefaults.standard.set(list3, forKey: "theUserData")
        UserDefaults.standard.set(list4, forKey: "theEmailData")
        
        print("the list3 issssssssssssss : ", UserDefaults.standard.array(forKey: "theEmailData"))
        print("the list4 isssssssssssss : ", list4)
        self.saveItem()
        self.userName.resignFirstResponder()
        
        
        
        
        
        //display alert message with confimation
        
        let myAlert = UIAlertController(title:"successful", message: "you add the user successfully, thank you", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present( myAlert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            //myAlert.dismiss(animated: true, completion: nil)
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
    
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // Delegate
    
    func saveItem()
    {
        var userName = self.userName.text

        var userID = ""

        userID = userName!
    
        
        self.delegate?.didSaveItem(userID,bookId)
        
    }
}
