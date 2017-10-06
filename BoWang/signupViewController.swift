//
//  signupViewController.swift
//  BoWang
//
//  Created by zhe on 2017/9/21.
//  Copyright © 2017年 Microsoft. All rights reserved.
//

import UIKit

class signupViewController: UIViewController {
    
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var repeatPasswordText: UITextField!
    
    @IBOutlet weak var emergeUser: UITextField!
//    
    @IBOutlet weak var telephone: UITextField!
    
    
    
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "login")
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var dicClient = [String:Any]()
    var dicClient2 = [String:Any]()
    //var list = NSMutableArray()
    var list2 = NSMutableArray()
    var list = NSMutableArray()
    var array:[Any] = []
    var array2:[Any] = []
    
    @IBAction func signupButton(_ sender: Any)
    {
        if (array2 != nil){
            list2 = array2 as! NSMutableArray
        }
        print("aaaaaaaaaaa: ", UserDefaults.standard.array(forKey: "theUserData"))
        print("bbbbbbbbbbbbb: ", UserDefaults.standard.array(forKey: "theEmailData"))
        print("ccccccccccccccccc: ", list2)
        
        let userEmail = emailText.text
        let userPassword = passwordText.text
        let userRepeatPassword = repeatPasswordText.text
        let userEmergeConnector = emergeUser.text
        let userTelephone = telephone.text
        
        //check empty
        if (userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)! ||
            (userEmergeConnector?.isEmpty)! || (userTelephone?.isEmpty)!{
            
            //display an alert message
            
            displayMyAlertMessage(userMessage: "all filed are required")
            
            return
        }
        
        //check if the username exist
        if (list2.contains(userEmail)){
            //display an alert message
            
            displayMyAlertMessage(userMessage: "the username is already been used")
            
            return
            
        }
        
        
        if (Int(userTelephone!) == nil ||
            userTelephone!.characters.count != 10) {
            
            //display an alert message
            
            displayMyAlertMessage(userMessage: "please enter a valid telephone number")
            
            return
        }
        
        //check if password match
        
        if (userPassword != userRepeatPassword) {
            
            //display an alert message
            
            displayMyAlertMessage(userMessage: "Passwords do not match")
            
            return
        }
        
        if (!list2.contains(userEmergeConnector)){
            //display an alert message
            
            displayMyAlertMessage(userMessage: "the emergency connector does not exist")
            print("lllllllllllll: ", list2)
            print("bbbbbbbbbbbbb: ", userEmergeConnector)
            return
            
        }
        //list = array as! NSMutableArray
        
        //store data
        
        UserDefaults.standard.set(userEmail, forKey: "userRegistEmail")
        UserDefaults.standard.set(userPassword, forKey: "userRegistPassword")
        UserDefaults.standard.synchronize()
        
        
        //print("bbbbbbbbbbbbb: ", self.list)
        self.dicClient["email"] = userEmail
        self.dicClient["password"] = userPassword
        self.dicClient["connector"] = userEmergeConnector
        
        self.dicClient2["email"] = userEmail
        
        array.append(dicClient as AnyObject)
        array2.append(dicClient2 as AnyObject)
        //self.list2.add(userEmail)
        //self.list.add(self.dicClient)
        UserDefaults.standard.set(array, forKey: "theUserData")
        UserDefaults.standard.set(array2, forKey: "theEmailData")
        
        
        
        let itemToInsert = ["email": userEmail, "password": userPassword, "connector": userEmergeConnector , "telephone":userTelephone ] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        self.itemTable.insert(itemToInsert) {
            
            (item, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                print("Error: " + (error! as NSError).description)
            }
        }
        
        UserDefaults.standard.set(array, forKey: "theUserData")
        UserDefaults.standard.set(array2, forKey: "theEmailData")
        
        //display alert message with confimation
        
        let myAlert = UIAlertController(title:"Alert", message: "registration is successful, thank you", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default){
            action in
            self.dismiss(animated: true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        self.present( myAlert, animated: true, completion: nil)
        
    }
    
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let queue2 = DispatchQueue(label: "com.appcoda.myqueue")
        queue2.sync {
            array =  (UserDefaults.standard.array(forKey: "theUserData")) as! [Any]
            array2 = UserDefaults.standard.array(forKey: "theEmailData") as! [Any]
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
