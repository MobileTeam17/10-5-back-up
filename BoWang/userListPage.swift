/*
 This class presents all the users in the accountbook
 1. The number of the book is incremented from 0
 2. Every accountbook have an unique number
 */
import Foundation
import UIKit
import CoreData



class userListPage: UITableViewController, ToDoItemDelegate2 {
    
    var table : MSSyncTable?
    var store : MSCoreDataStore?
    var list = NSMutableArray()
    var dicClient = [String:Any]()
    var refresh : UIRefreshControl!
    var theValue = ""
    var bookId = ""
    var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
    var owner = ""
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "book_users")
    
    @IBOutlet weak var hello: UILabel!
    
    
    override func viewDidLoad() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate.client
        itemTable = client2.table(withName: "book_users")
        if UserDefaults.standard.string(forKey: "selectedBookId") != nil{
            bookId = UserDefaults.standard.string(forKey: "selectedBookId")!
        }
        
        refresh = UIRefreshControl()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        list = NSMutableArray()
        tableView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
        refresh.addTarget(self,action:#selector(billListAndDetail.refreshData(_:)), for: UIControlEvents.valueChanged)
        
        //save the accountbook id
        if UserDefaults.standard.string(forKey: "selectedBookId") != nil{
            UserDefaults.standard.set(bookId, forKey: "selectedBookId")
        }
        
        let queue = DispatchQueue(label: "com.appcoda.myqueue")
        queue.sync {
            
            //read 'bookid' and 'user' from the book_user table
            itemTable.read { (result, error) in
                var ss = ""
                if let err = error {
                    print("ERROR ", err)
                } else if let items = result?.items {
                    print("the item list is : ", items.count)
                    for item in items {
                        self.dicClient["theUser"] = "\(item["theUser"]!)"
                        if "\(item["bookId"]!)" == self.bookId{
                            if !self.list.contains(self.dicClient){
                                self.list.add(self.dicClient)
                                ss = "\(item["bookId"]!)"
                                print("the book is : ", ss)
                                print("the size is : ", self.list)
                                self.tableView.reloadData()
                            }
                        }
                        //tip: here we present the same line for several time because we still get confuesed about the execution order of swift
                        self.tableView.reloadData()
                        self.tableView.reloadData()
                        self.refreshData(self.refresh)
                        self.refreshData(self.refresh)
                    }
                    
                }
            }
        }
        
        
        let client = delegate.client
        let itemTable2 = client.table(withName: "AccountBook")
        itemTable2.read { (result, error) in
            var ss = ""
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    self.dicClient["theUser"] = "\(item["owner"]!)"
                    if "\(item["owner"]!)" == self.loginName{
                        if !self.list.contains(self.dicClient){
                            self.list.add(self.dicClient)
                            ss = "\(item["owner"]!)"
                            print("the book is : ", ss)
                            print("the size is : ", self.list)
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                    self.tableView.reloadData()
                    self.refreshData(self.refresh)
                    self.refreshData(self.refresh)
                }
            }
        }
        
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        
        self.refreshData(self.refreshControl)
        self.refreshData(self.refreshControl)
        self.refreshData(self.refreshControl)
        self.refreshData(self.refreshControl)
        print("the transfer bookId is : ", self.bookId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        tableView.reloadData()
        tableView.reloadData()
    }
    
    func refreshData(_ sender: UIRefreshControl!){
        tableView.reloadData()
    }
    
    
    func showExample(_ segueId: String) {
        performSegue(withIdentifier: segueId, sender: nil)
    }
    
    
    func onRefresh(_ sender: UIRefreshControl!) {
        tableView.reloadData()
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
        viewDidLoad()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("the number is : ", list.count)
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let client = self.list[indexPath.row] as! [String:String]
        cell.textLabel?.text =  client["theUser"] as! String
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        super.viewDidLoad()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let client = self.list[indexPath.row] as! [String:String]
        theValue = client["theUser"] as! String
        
    }
    
    //back to bill list
    @IBAction func back(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(bookId, forKey: "selectedBookId")
        
    }
    
    //prepared to link to another page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addUser" {
            let todoController = segue.destination as! addNewUserToBook
            todoController.delegate = self
        }
        
    }
    
    
    @IBAction func home(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //save data
    func didSaveItem(_ theUser: String, _ bookId: String)
    {
        if theUser.isEmpty {
            return
        }
        if bookId.isEmpty {
            return
        }
        
        // We set created at to now, so it will sort as we expect it to post the push/pull
        let itemToInsert = ["theUser": theUser, "bookId": bookId, "__createdAt": Date()] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.itemTable.insert(itemToInsert) {
            
            (item, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                print("Error: " + (error! as NSError).description)
            }
        }
        
        self.dicClient["theUser"] = "\(itemToInsert["theUser"]!)"
        self.dicClient["bookId"] = "\(itemToInsert["bookId"]!)"
        self.dicClient["createdAt"] = "\(itemToInsert["__createdAt"]!)"
        self.list.add(self.dicClient)

        Thread.sleep(forTimeInterval: 2)
        
        viewDidLoad()
        self.tableView.reloadData()
    }
    
}






