/*
 This class is for sign up page
 1. we need to write personal details
 2. store those details to cloud
 */

import UIKit

class signupViewController: UIViewController, UITextFieldDelegate {
    
    //details need to write in
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPasswordText: UITextField!
    @IBOutlet weak var emergeUser: UITextField!
    @IBOutlet weak var telephone: UITextField!
    
    //table from Azure
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "login")
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    //local 'dic' and 'list' for cache
    var dicClient = [String:Any]()
    var dicClient2 = [String:Any]()
    var list2 = NSMutableArray()
    var list = NSMutableArray()
    var array:[Any] = []
    var array2:[Any] = []
    
    //This function is to signup, when we click the button, all data will be saved and sent to Azure
    @IBAction func signupButton(_ sender: Any)
    {
        if (array2 != nil){
            list2 = array2 as! NSMutableArray
        }
   
        let userEmail = emailText.text
        let userPassword = passwordText.text
        let userRepeatPassword = repeatPasswordText.text
        let userEmergeConnector = emergeUser.text
        let userTelephone = telephone.text
        
        //check empty
        if (userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)! ||
            (userTelephone?.isEmpty)!{
            //display an alert message
            displayMyAlertMessage(userMessage: "all filed are required")
            return
        }
        
        //check if the username exist
        if (list2.contains(userEmail)){
            displayMyAlertMessage(userMessage: "the username is already been used")
            return
        }
        
        //must be right format for telephone
        if (Int(userTelephone!) == nil ||
            userTelephone!.characters.count != 10) {
            displayMyAlertMessage(userMessage: "please enter a valid telephone number")
            return
        }
        
        //check if password match
        if (userPassword != userRepeatPassword) {
            displayMyAlertMessage(userMessage: "Passwords do not match")
            return
        }
        
        //check if the emergency connector exist
        if (!(userEmergeConnector?.isEmpty)! &&
            !list2.contains(userEmergeConnector)){
            displayMyAlertMessage(userMessage: "the emergency connector does not exist")
            return
        }
       
        //store data(both to 'userDefaults', 'dic' and 'list'
        UserDefaults.standard.set(userEmail, forKey: "userRegistEmail")
        UserDefaults.standard.set(userPassword, forKey: "userRegistPassword")
        UserDefaults.standard.synchronize()
        self.dicClient["email"] = userEmail
        self.dicClient["password"] = userPassword
        self.dicClient["connector"] = userEmergeConnector
        self.dicClient2["email"] = userEmail
        array.append(dicClient as AnyObject)
        array2.append(dicClient2 as AnyObject)
        UserDefaults.standard.set(array, forKey: "theUserData")
        UserDefaults.standard.set(array2, forKey: "theEmailData")
        
        
        //insert those object to Azure table
        let itemToInsert = ["email": userEmail, "password": userPassword, "connector": userEmergeConnector , "telephone":userTelephone ] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.itemTable.insert(itemToInsert) {
            
            //here is to ckeck whether the network is available
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
    
    //This function can display an alert
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }

    //view
    override func viewDidLoad() {
        self.emailText.delegate = self
        super.viewDidLoad()
        let queue2 = DispatchQueue(label: "com.appcoda.myqueue")
        queue2.sync {
            array =  (UserDefaults.standard.array(forKey: "theUserData")) as! [Any]
            array2 = UserDefaults.standard.array(forKey: "theEmailData") as! [Any]
        }
    }
    
    //view(coming)
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
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
