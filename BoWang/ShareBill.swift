/*
 This class is shareBill page
 1. We get all the cost from the table 'billListAndDetail'
 */

import Foundation
import UIKit

class ShareBill: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate, ToDoItemDelegate  {
    
    var list = NSMutableArray()
    var dicClient = [String:Any]()
    var refresh : UIRefreshControl!
    var value = ""
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var itemTable = (UIApplication.shared.delegate as! AppDelegate).client.table(withName: "table2")
    var owner = ""
    var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
    var bookId = ""
    var sum : Double = Double()
    var cost = NSMutableArray()
    
    
    @IBOutlet weak var hello: UILabel!
    @IBOutlet weak var SUM: UILabel!
    @IBOutlet weak var ShareBill: UILabel!
    
    
    override func viewDidLoad(){
        
        if UserDefaults.standard.string(forKey: loginName!) != nil{
            bookId = UserDefaults.standard.string(forKey: loginName!)!
        }
        
        //refresh the page with setting below
        refresh = UIRefreshControl()
        list = NSMutableArray()
        refresh.backgroundColor = UIColor.darkGray
        refresh.attributedTitle = NSAttributedString(string: "reload the bill information")
        refresh.addTarget(self, action: #selector(billListAndDetail.refreshData(_:)), for: UIControlEvents.valueChanged)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate.client
        var username : [String] = [String]()
        var bookuser : [String] = [String]()
        
        //read all the users in the same accountbook
        itemTable = client2.table(withName: "book_users")
        itemTable.read { (result, error) in
            var ss = ""
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    
                    //get 'user', 'bookid',
                    self.dicClient["id"] = "\(item["id"]!)"
                    self.dicClient["theUser"] = "\(item["theUser"]!)"
                    self.dicClient["bookId"] = "\(item["bookId"]!)"
                    if "\(item["bookId"]!)" == self.bookId{
                        if !self.list.contains(self.dicClient){
                            self.list.add(self.dicClient)
                            ss = "\(item["bookId"]!)"
                            bookuser.append(item["theUser"] as! String)
                        }
                    }
                    self.refreshData(self.refresh)
                    self.refreshData(self.refresh)
                }
            }
        }
        
        //read all bills from the accountbook
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
                                
                                //get the total cost
                                self.sum += Double(item["theCost"] as! String)!
                                if !self.list.contains(self.dicClient){
                                    self.list.add(self.dicClient)
                                }
                                
                                //store all users in a string
                                if ("\(item["accountBookId"]!)" == self.bookId) && (item["spendBy"] != nil) && !(username.contains(item["spendBy"] as!  String )){
                                    username.append(item["spendBy"] as! String)
                                }
                            }
                        }
                    }
                }
                
                
                
                self.SUM.text = String(self.sum)
                let items = result?.items
                var spend : [Double] = [Double]()
                var should_give : [Double] = [Double]()
                var count = 0
                
                //to find someone who really need to share the bill, but not spend any money
                //the one spend money is on username
                //all user are store in bookuser
                if bookuser.count > username.count{
                    for index in 1...bookuser.count{
                        if !username.contains(bookuser[index-1]){
                            username.append(bookuser[index-1])
                        }
                    }
                    count = bookuser.count
                }
                else {
                    count = username.count
                }
                
                //Must have more than one peopel to share the bill
                if count == 0{
                    self.ShareBill.text = "You do not need to share bill with others."
                }
                else if count == 1{
                    spend.append(self.sum)
                    self.ShareBill.text = "You do not need to share bill with others."
                }
                else{
                    for index in 1...count{
                        spend.append(0)
                        for item in items!{
                            
                            //select the men with their cost
                            //everyone's cost saved in 'spend[]'
                            if ("\(item["accountBookId"]!)" == self.bookId) && (item["spendBy"] as! String == username[index-1] ){
                                var sum = spend[index-1]
                                var new = sum + Double(item["theCost"] as! String!)!
                                spend[index-1] = new
                            }
                        }
                    }
                    
                    //count the average
                    var average = self.sum/Double(count)
                    var costlist = NSMutableArray()

                    //calculate the money that everyone should pay
                    for index in 1...count{
                        should_give.append(-(spend[index-1] - average))
                    }
                    
                    //'printvar' save all the infor will display on the screen
                    //The general idea of the algorithm is that：
                    //1. Everyone should pay the money minus the average consumption of all
                    //2. Execute a 'for' loop: The first person should pay(receive) how much money to the backs
                    // when the money comes to 0, it goes to the next person's loop
                    var printvar :[String] = [String]()
                    self.ShareBill.text = ""
                    for i in 1...count{
                        if should_give[i-1] > 0{
                            for j in 1...count{
                                if should_give[j-1] < 0 && should_give[i-1] > 0 {
                                    print("c")
                                    if -(should_give[j-1]) >= should_give[i-1]{
                                        print("d")
                                        should_give[j-1] += should_give[i-1]
                                        printvar.append ("\(username[i-1] ) should give \(username[j-1]) $ \(Int(should_give[i-1])) \n")
                                        should_give[i-1] = 0
                                    }
                                    else if -(should_give[j-1]) < should_give[i-1]{
                                        print("e")
                                        should_give[i-1] = should_give[i-1] + should_give[j-1]
                                        printvar.append("\(username[i-1] ) should give \(username[j-1]) $ \(Int(-should_give[j-1])) \n")
                                        should_give[j-1] = 0
                                        
                                    }
                                }
                            }
                        }
                    }
                    for index in 1...printvar.count{
                        self.ShareBill.text?.append(printvar[index-1])
                    }
                }
            }
        }
    }
    
    func refreshData(_ sender: UIRefreshControl!){
        
        refresh.endRefreshing()
    }

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

        self.dicClient["label"] = "\(itemToInsert["label"]!)"
        self.dicClient["theCost"] = "\(itemToInsert["theCost"]!)"
        self.dicClient["createdAt"] = "\(itemToInsert["__createdAt"]!)"
        self.dicClient["spendBy"] = loginName
        self.dicClient["accountBookId"] = bookId
        
        self.list.add(self.dicClient)
    }
}


