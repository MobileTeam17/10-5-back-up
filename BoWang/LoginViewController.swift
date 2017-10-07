/*
 This Class is for login page
 The steps are:
 1. get the DATA(username, password) from the cloud
 2. text in the login INFO
 3. compare the DATA with INFO to let user login
*/
 
import Foundation
import UIKit
import Firebase
import FirebaseDatabase

protocol ToDoItemDelegate4 {
    func didSaveItem(_ theUser: String, _ bookId: String)
}

class LoginViewController: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate {
    
    //to test email and password
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    //Tables from the cloud -- Azure
    var itemTable2 = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "book_users")
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "login")
    
    //list and dic for sotre data read form the cloud
    var bookIdList = NSMutableArray()
    var loginName = ""
    var list = NSMutableArray()
    var list2 = NSMutableArray()
    var list3 = NSMutableArray()
    var dicClient = [String:Any]()
    var dicClient2 = [String:Any]()
    var dicClient3 = [String:Any]()
    
    
    override func viewDidLoad()
    {

        self.emailText.delegate = self
        super.viewDidLoad()
        
        observeMessages()

        //read data from the Azure -- for more datial, it read the useremail(username) and password
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client = delegate.client
        itemTable = client.table(withName: "login")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if !self.list.contains("\(item["email"]!)"){
                        self.list.add("\(item["email"]!)")
                    }
                    self.dicClient["email"] = "\(item["email"]!)"
                    self.dicClient["password"] = "\(item["password"]!)"
                    if !self.list2.contains(self.dicClient){
                        self.list2.add(self.dicClient)
                    }
                    //after each loop, we will store data in 'Userdefaults'
                    UserDefaults.standard.set(self.list2, forKey: "theUserData")
                    UserDefaults.standard.set(self.list, forKey: "theEmailData")
                }
                UserDefaults.standard.set(self.list2, forKey: "theUserData")
                UserDefaults.standard.set(self.list, forKey: "theEmailData")
            }
        }
        UserDefaults.standard.set(list2, forKey: "theUserData")
        UserDefaults.standard.set(list, forKey: "theEmailData")
    }
    
    //Show an alert and receive the message from others
    //which means you are the emergency contact of others and they send message to you
    func observeMessages(){
        
        let ref = Database.database().reference().child("message")
        ref.observe(.childAdded, with: { (DataSnapshot) in
            let theMessage = "\(DataSnapshot.value!)" as? String
            var key = "\(DataSnapshot.key)" as? String
            

            self.dicClient3[key!] = theMessage
            if key  == "text"{
                self.dicClient3["text"] = theMessage
            }
            if key  == "toId" {
                self.dicClient3["toId"] = theMessage
            }
            if key  == "fromId" {
                self.dicClient3["text"] = ""
            }
            if (self.dicClient3["text"] as? String == "" ||
                self.dicClient3["toId"] as? String == "" ||
                self.dicClient3["fromId"] as? String == "") {
                var dicClient3 = [String:Any]()
            }
            self.list3.add(self.dicClient3)
            
            //The following is to add new object into list and store in 'uerdefault'
            let fff = self.list3.lastObject as? [String:Any]
            if (fff?["text"] as? String != "" &&
                fff?["toId"] as? String != "" &&
                fff?["fromId"] as? String != "") {
                self.dicClient3["text"] = fff?["text"]
                self.dicClient3["toId"] = fff?["toId"]
                self.dicClient3["fromId"] = fff?["fromId"]
                self.list3.add(self.dicClient3)
                
                //store data
                UserDefaults.standard.set(self.dicClient3 , forKey: "Messages")
                UserDefaults.standard.set(self.dicClient3["text"] as? String, forKey: "theMessages")
                UserDefaults.standard.set(self.dicClient3["toId"] as? String, forKey: "receiveId")
                UserDefaults.standard.set(self.dicClient3["fromId"] as? String, forKey: "fromId")
            }
        })
        
    }
    
    
    //This function is to clean all data in 'UserDefaults'
    func clearAllUserDefaultsData(){
        let userDefaults = UserDefaults.standard
        let dics = userDefaults.dictionaryRepresentation()
        for key in dics {
            userDefaults.removeObject(forKey: key.key)
        }
        userDefaults.synchronize()
    }
    
    
    
    //present the view
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client = delegate.client
        itemTable = client.table(withName: "login")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if !self.list.contains("\(item["email"]!)"){
                        self.list.add("\(item["email"]!)")
                        UserDefaults.standard.set(self.list, forKey: "theEmailData")
                    }
                    
                    self.dicClient["email"] = "\(item["email"]!)"
                    self.dicClient["password"] = "\(item["password"]!)"
                    if !self.list2.contains(self.dicClient){
                        self.list2.add(self.dicClient)
                    }
                    UserDefaults.standard.set(self.list2, forKey: "theUserData")
                    
                }
            }
        }
        UserDefaults.standard.set(list2, forKey: "theUserData")
        UserDefaults.standard.set(list, forKey: "theEmailData")
        
        
        observeMessages()
    }
    
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        viewDidLoad()
        self.setNeedsFocusUpdate()

        let userEmail = emailText.text
        let userPassword = passwordText.text
        
        //send 'email' and 'password' to server
        //here just read email and password
        self.dicClient["email"] = userEmail
        self.dicClient["password"] = userPassword
        
        //the following steps are for login ckecking, wheather the user tap in the right email or password
        if list.contains(userEmail){
            if list2.contains(dicClient){
                //mark that user is login
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                
            }
            else{
                displayMyAlertMessage(userMessage: "Wrong Password!")
                return
            }
        }
        else {
            displayMyAlertMessage(userMessage: "The name does not exist!")
            return
        }
        
        UserDefaults.standard.set(userEmail, forKey: "userRegistEmail")
        UserDefaults.standard.set(self.dicClient3["text"] as? String, forKey: "theMessages")
        UserDefaults.standard.set(self.dicClient3["toId"] as? String, forKey: "receiveId")

        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if "\(item["email"]!)" == userEmail{
                        UserDefaults.standard.set("\(item["connector"]!)" as? String, forKey: "theconnector")
                        print("the connector isssssss", "\(item["connector"]!)")
                    }
                }
            }
        }

        performSegue(withIdentifier: "login", sender: nil)
        
    }
    
    //This function is to show an alert
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        
        //show an 'ok' button
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
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
    }
    
    
}
