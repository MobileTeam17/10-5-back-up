
//  accountBookList.swift


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
        
        refresh = UIRefreshControl()
        
        let queue2 = DispatchQueue(label: "com.appcoda.myqueue")
        //queue2.sync {
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
                print("234456677888888", self.bookIdList)
                self.tableView.reloadData()
            }
        }
        //}
        self.tableView.reloadData()
        
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
                print("8888888888888888", self.bookIdList)
                self.tableView.reloadData()
            }
        }
        self.tableView.reloadData()
        
        getBookList()
        
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
    
    
    func refreshData(_ sender: UIRefreshControl!){
        
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    func getBookList() {
        list = NSMutableArray()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate.client
        itemTable = client2.table(withName: "AccountBook")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                print("979797979797", self.bookIdList)
                for item in items {
                    if self.bookIdList.contains("\(item["id"]!)"){
                        self.dicClient["bookName"] = "\(item["bookName"]!)"
                        self.dicClient["id"] = "\(item["id"]!)"
                        //self.dicClient["createdAt"] = "\(item["__createdAt"]!)"
                        if !self.list.contains(self.dicClient){
                            self.list.add(self.dicClient)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    func displayMyAlertMessage(userMessage: String)  {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    
    func showExample(_ segueId: String) {
        performSegue(withIdentifier: segueId, sender: nil)
    }
    
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("the size is : ", list.count)
        
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier = "Cell"
        
        //var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //cell = configureCell(cell, indexPath: indexPath)
        
        let client = self.list[indexPath.row] as! [String:String]
        
        cell.textLabel?.text =  client["bookName"] as! String
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        
        super.viewDidLoad()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let client = self.list[indexPath.row] as! [String:String]
        
        theValue = client["bookName"] as! String
        selectedBookId = client["id"]!
        
        UserDefaults.standard.set(selectedBookId, forKey: loginName!)
        performSegue(withIdentifier: "billListAndDetail", sender: nil)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addBook" {
            let todoController = segue.destination as! addNewBook
            todoController.delegate = self
            getMaxBookId()
            print("12121212112112 : ", maxmumBookId)
        }
        
        if(segue.identifier == "getLocation") {
            //UserDefaults.standard.set(selectedBookId, forKey: "selectedBookId")
            
        }
        
        
        if(segue.identifier == "billListAndDetail") {
            UserDefaults.standard.set(selectedBookId, forKey: "selectedBookId")
            
        }
    }
    
    
    
    @IBAction func home(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
    
    // MARK: - ToDoItemDelegate
    
    
    func didSaveItem(_ newBookName: String)
    {
        print("98888888888: ", newBookName)
        
        if newBookName.isEmpty {
            return
        }
        
        
        // We set created at to now, so it will sort as we expect it to post the push/pull
        let itemToInsert = ["id": String(maxmumBookId+1), "bookName": newBookName, "owner": self.loginName, "__createdAt": Date()] as [String : Any]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print("98888888888: ", itemToInsert)
        
        self.itemTable.insert(itemToInsert) {
            
            (item, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                print("Error: " + (error! as NSError).description)
            }
        }
        
        self.dicClient["bookName"] = "\(itemToInsert["bookName"]!)"
        self.dicClient["owner"] = "\(itemToInsert["owner"]!)"
        self.dicClient["createdAt"] = "\(itemToInsert["__createdAt"]!)"
        self.dicClient["id"] = "\(itemToInsert["id"]!)"
        print("the list is : ", self.dicClient["bookName"])
        print("the list is : ", self.dicClient["owner"])
        print("the list is : ", self.dicClient["createdAt"])
        print("the list is : ", self.dicClient["id"])
        
        self.list.add(self.dicClient)
        print("the list is : ", self.list)
        print("the max Book Id is : ", maxmumBookId)
        Thread.sleep(forTimeInterval: 2)
        
        viewDidLoad()
        
        self.tableView.reloadData()
        
        
        viewDidLoad()
    }
    
}






