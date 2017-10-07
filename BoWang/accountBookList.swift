/*
 This class is to add a new account book and present all the account books
 1. The number of the book is incremented from 0
 2. Every accountbook have an unique number
 
 */
import Foundation
import UIKit
import CoreData
import Firebase
import FirebaseDatabase


class accountBookList: UITableViewController, ToDoItemDelegate3 {
    
    var store : MSCoreDataStore?
    var list = NSMutableArray()
    var dicClient = [String:Any]()
    var refresh : UIRefreshControl!
    var theValue = ""
    var theMessage = ""
    var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
    
    var selectedBookId = ""
    var bookIdList = NSMutableArray()
    var itemTable2 = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "book_users")
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "AccountBook")
    var maxmumBookId = 0
    
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //refresh the page
        refresh = UIRefreshControl()
        
        //read data(users) form Azure
        let delegate2 = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate2.client
        itemTable2 = client2.table(withName: "book_users")
        itemTable2.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if "\(item["theUser"]!)" == self.loginName! &&
                        !self.bookIdList.contains("\(item["bookId"]!)"){
                        self.bookIdList.add("\(item["bookId"]!)")
                    }
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
            }
        }
        self.tableView.reloadData()
        
        //read data(accountbook) from Azure, which will return a booklist
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client = delegate.client
        itemTable = client.table(withName: "AccountBook")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if "\(item["owner"]!)" == self.loginName! &&
                        !self.bookIdList.contains("\(item["id"]!)"){
                        self.bookIdList.add("\(item["id"]!)")
                    }
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
            }
        }
        self.tableView.reloadData()
        
        getBookList()
        
        //???
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        self.refreshControl?.beginRefreshing()
        self.refreshData(self.refreshControl)
        
        getBookList()
        
        if (theMessage != ""){
            displayMyAlertMessage(userMessage: theMessage)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        getBookList()
        tableView.reloadData()
    }
    
    //This function can reload the data
    func refreshData(_ sender: UIRefreshControl!){
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    //This function can the account book name
    func getBookList() {
        list = NSMutableArray()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate.client
        itemTable = client2.table(withName: "AccountBook")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if self.bookIdList.contains("\(item["id"]!)"){
                        self.dicClient["bookName"] = "\(item["bookName"]!)"
                        self.dicClient["id"] = "\(item["id"]!)"
                        if !self.list.contains(self.dicClient){
                            self.list.add(self.dicClient)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    //This function can display an alert
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    
    
    //refresh the page
    func onRefresh(_ sender: UIRefreshControl!) {
        tableView.reloadData()
        if (theMessage != ""){
            displayMyAlertMessage(userMessage: theMessage)
        }
        refresh.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Table Controls
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Complete"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    //return the list number
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return list.count
    }
    
    //view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let client = self.list[indexPath.row] as! [String:String]
        cell.textLabel?.text =  client["bookName"] as! String
        tableView.reloadRows(at: [indexPath], with: .automatic)
        super.viewDidLoad()
        return cell
    }
    
    //present the table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let client = self.list[indexPath.row] as! [String:String]
        theValue = client["bookName"] as! String
        selectedBookId = client["id"]!
        UserDefaults.standard.set(selectedBookId, forKey: loginName!)
        performSegue(withIdentifier: "billListAndDetail", sender: nil)
    }
    
    //Get prepared when you want to link to another page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBook" {
            let todoController = segue.destination as! addNewBook
            todoController.delegate = self
            getMaxBookId()
        }
        if(segue.identifier == "getLocation") {
            
        }
        if(segue.identifier == "billListAndDetail") {
            UserDefaults.standard.set(selectedBookId, forKey: "selectedBookId")  
        }
    }
    
    
    @IBAction func home(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Give every book an special id
    func getMaxBookId(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client = delegate.client
        let itemTable3 = client.table(withName: "AccountBook")
        var maxBookId = 0
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if Int("\(item["id"]!)")! > maxBookId{
                        maxBookId = Int("\(item["id"]!)")!
                    }
                }
            }
            self.maxmumBookId = maxBookId
        }
    }
    
    //save data to Azure
    func didSaveItem(_ newBookName: String)
    {
        if newBookName.isEmpty {
            return
        }
        
        // We set created at to now, so it will sort as we expect it to post the push/pull
        let itemToInsert = ["id": String(maxmumBookId+1), "bookName": newBookName, "owner": self.loginName, "__createdAt": Date()] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.itemTable.insert(itemToInsert) {
            (item, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
            }
        }
        
        //insert data to booklist
        let itemToInsert2 = ["theUser": self.loginName, "bookId": String(maxmumBookId+1), "__createdAt": Date()] as [String : Any]
        self.itemTable2.insert(itemToInsert2) {
            
            (item, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                print("Error: " + (error! as NSError).description)
            }
        }
        
        //Store data in local 'dic'
        self.dicClient["bookName"] = "\(itemToInsert["bookName"]!)"
        self.dicClient["owner"] = "\(itemToInsert["owner"]!)"
        self.dicClient["createdAt"] = "\(itemToInsert["__createdAt"]!)"
        self.dicClient["id"] = "\(itemToInsert["id"]!)"
        self.list.add(self.dicClient)
        Thread.sleep(forTimeInterval: 2)
        
        viewDidLoad()
        
        self.tableView.reloadData()
        
        viewDidLoad()
    }
    
}

