/*
 This class can let user to add a new bill
 1. The bill have several properties(usage, cost, location, etc.)
 2. We gater the bill data and store to Azure table 'billLIstAndDatials'
 3. we present these properties in a cell
 4. When the user login, it will first read all the data and present in the cell
 */

import Foundation
import UIKit

class billListAndDetail: UITableViewController, ToDoItemDelegate  {
    
    var list = NSMutableArray()
    var dicClient = [String:Any]()
    var refresh : UIRefreshControl!
    var value = ""
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "table2")
    var owner = ""
    var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
    var bookId = ""
    var sendId = ""
    
    @IBOutlet weak var hello: UILabel!
    
    override func viewDidLoad() {
        
        //get the loginName and emergency contact
        if UserDefaults.standard.string(forKey: loginName!) != nil{
            bookId = UserDefaults.standard.string(forKey: loginName!)!
        }
        
        if UserDefaults.standard.string(forKey: "theMessages")  != nil &&
            UserDefaults.standard.string(forKey: "theMessages")  != ""{
            var name  = UserDefaults.standard.string(forKey: "receiveId")
            sendId = UserDefaults.standard.string(forKey: "fromId")!
            var message = UserDefaults.standard.string(forKey: "theMessages")!
            if (name == loginName){
                displayMyAlertMessage2(userMessage: "  Hello, I am in: \(message) !  I need your help ~" )
                UserDefaults.standard.set(nil, forKey: "theMessage")
            }
        }
        
        //a welcome view and refresh the page
        hello.text = "  Hello:  \(loginName!) !  welcome to the app"
        refresh = UIRefreshControl()
        super.viewDidLoad()
        
        list = NSMutableArray()
        tableView.reloadData()
        
        
        tableView.dataSource=self
        refresh.backgroundColor = UIColor.darkGray
        refresh.attributedTitle = NSAttributedString(string: "reload the bill information")
        refresh.addTarget(self, action: #selector(billListAndDetail.refreshData(_:)), for: UIControlEvents.valueChanged)
        
        //read 'id', 'label', 'creatTime', 'theCost', 'updateTime' and 'spendBy' from the table 'billListAndDetails'
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate.client
        itemTable = client2.table(withName: "billListAndDetails")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if self.bookId == ""{
                    }
                    else{
                        if "\(item["deleted"]!)" == "0"{
                            if "\(item["accountBookId"]!)" == self.bookId {
                                self.dicClient["id"] = "\(item["id"]!)"
                                self.dicClient["label"] = "\(item["label"]!)"
                                self.dicClient["createdAt"] = "\(item["createdAt"]!)"
                                self.dicClient["theCost"] = "\(item["theCost"]!)"
                                self.dicClient["updatedAt"] = "\(item["updatedAt"]!)"
                                self.dicClient["spendBy"] = "\(item["spendBy"]!)"
                                if !self.list.contains(self.dicClient){
                                    self.list.add(self.dicClient)
                                }
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
        
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        self.refreshControl?.beginRefreshing()
        self.refreshData(self.refreshControl)
        
    }
    
    //refresh data
    func refreshData(_ sender: UIRefreshControl!){
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    
    
    @IBAction func backPage(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //get the size
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create a cell to present the datials
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let client = self.list[indexPath.row] as! [String:String]
        cell.textLabel?.text =  "$ \(client["theCost"]!)  "
        let str = " \(client["label"]!)"
        var str2 = "   "+client["createdAt"]!
        var str3 = " by "+client["spendBy"]!
        
        for i in 0 ..< 14 {
            str2.remove(at: str2.index(before: str2.endIndex))
        }
        cell.detailTextLabel?.text = "\(str) \(str2) \(str3)"
        cell.imageView?.image = UIImage(named: "test1")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete the bill
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            while self.list.contains(self.list.index(of: indexPath.row))   {
                self.list.remove(at: indexPath.row)
            }
            
            var item = [String:Any]()
            item = self.list.object(at: indexPath.row) as! [String : Any]
            let sss = item["id"]
            self.itemTable.delete(withId: sss) { (id, error) in
                if let err = error {
                    print("ERROR ", err)
                } else {
                    print("Todo Item ID: ", id)
                }
                
            }
            
            self.itemTable.delete(withId: sss) { (id, error) in
                if let err = error {
                    print("ERROR ", err)
                } else {
                    print("Todo Item ID: ", id)
                }
            }
        }
        
        viewDidLoad()
        viewDidLoad()
        self.tableView.reloadData()
        
    }
    
    // MARK: Navigation
    //add a new bill
    @IBAction func addItem(_ sender: Any) {
        self.performSegue(withIdentifier: "addItem", sender: self)
        
    }
    
    
    //prepare when link to another page
    override func prepare(for segue: UIStoryboardSegue, sender: Any!)
    {
        if segue.identifier == "addItem" {
            let todoController = segue.destination as! addNewBill
            todoController.delegate = self
        }
        
        if(segue.identifier == "userPage") {
            let todoController = segue.destination as! userListPage
            if self.bookId == ""{
                displayMyAlertMessage(userMessage: "select a account book first!")
                return
            }
            else{
                todoController.bookId = self.bookId
            }
        }
    }
    
    //This alert will show immediatly when user login in this app
    //Content is: someone else sent to ask for help SMS
    func displayMyAlertMessage2(userMessage: String)  {
        let myAlert = UIAlertController(title:"  Send from:  \(sendId)  ", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        UserDefaults.standard.set("", forKey: "theMessages")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //display alert
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // MARK: - ToDoItemDelegate
    //save data
    func didSaveItem(_ label: String, _ theCost: String, _ describetion: String)
    {
        if label.isEmpty {
            return
        }
        if theCost.isEmpty {
            return
        }
        if describetion.isEmpty {
            return
        }
        
        // We set created at to now, so it will sort as we expect it to post the push/pull
        let itemToInsert = ["label": label, "theCost": theCost, "owner": owner,"describ":describetion, "__createdAt": Date(), "spendBy": loginName, "accountBookId": bookId] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.itemTable.insert(itemToInsert) {
            
            (item, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                print("Error: " + (error! as NSError).description)
            }
        }
        
        
        //save to the loacl 'dic' and then save to a list
        self.dicClient["label"] = "\(itemToInsert["label"]!)"
        self.dicClient["theCost"] = "\(itemToInsert["theCost"]!)"
        self.dicClient["createdAt"] = "\(itemToInsert["__createdAt"]!)"
        self.dicClient["spendBy"] = loginName
        self.dicClient["accountBookId"] = bookId
        
        self.list.add(self.dicClient)
        
        viewDidLoad()
        viewDidLoad()
        self.tableView.reloadData()
    }
}
