//
//  Report.swift
//  BoWang
//
//  Created by Peach on 2017/9/28.
//  Copyright © 2017年 Microsoft. All rights reserved.
//

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
        
        //hello.text = "  Hello:  \(loginName!) !  welcome to the app"
        refresh = UIRefreshControl()
      
        
        list = NSMutableArray()
  
        refresh.backgroundColor = UIColor.darkGray
        refresh.attributedTitle = NSAttributedString(string: "reload the bill information")
        refresh.addTarget(self, action: #selector(billListAndDetail.refreshData(_:)), for: UIControlEvents.valueChanged)
        
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client2 = delegate.client
        var username : [String] = [String]()
        //var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
        var bookuser : [String] = [String]()
        
        
        itemTable = client2.table(withName: "book_users")
        itemTable.read { (result, error) in
            var ss = ""
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                print("the item list is : ", items.count)
                for item in items {
                    self.dicClient["id"] = "\(item["id"]!)"
                    self.dicClient["theUser"] = "\(item["theUser"]!)"
                    self.dicClient["bookId"] = "\(item["bookId"]!)"
                    print("sharebill before \(bookuser)")
                    if "\(item["bookId"]!)" == self.bookId{
                        
                        
                        if !self.list.contains(self.dicClient){
                            
                            self.list.add(self.dicClient)
                            ss = "\(item["bookId"]!)"
                            
                            bookuser.append(item["theUser"] as! String)
                            print("sharebill after \(bookuser)")
                            print("the book is : ", ss)
                            //print("the size is : ", self.list)
                           
                            
                            
                            print("1111111: ", self.list.count)
                        }
                    }
                    
                 
                    self.refreshData(self.refresh)
                    self.refreshData(self.refresh)
                    
                }
                
            }
        }
    

        print("sharebill user: \(bookuser)")
        
        
        
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
                                
                                self.sum += Double(item["theCost"] as! String)!
                                //print(self.sum)
                                print(self.dicClient["spendBy"])
                                if !self.list.contains(self.dicClient){
                                    self.list.add(self.dicClient)
                                }
                                print(self.bookId)
                                if ("\(item["accountBookId"]!)" == self.bookId) && (item["spendBy"] != nil) && !(username.contains(item["spendBy"] as!  String )){
                                        username.append(item["spendBy"] as! String)
                                        print(username)
                                }
                                
                                
                                
                            }
                        }
                    }
                    
                    
                }
                
                
                
                self.SUM.text = String(self.sum)
                print(username)
                print(username.count)
                let items = result?.items
                var spend : [Double] = [Double]()
               
                var should_give : [Double] = [Double]()
                var count = 0
                
                if bookuser.count > username.count{
                    
                    for index in 1...bookuser.count{
                        if !username.contains(bookuser[index-1]){
                            username.append(bookuser[index-1])
                        }
                    }
                    
                    
                    count = bookuser.count
                    print("> \(count)")
                    print("> \(username)")
                }
                else {
                    
                    count = username.count
                    print("= \(count)")
                }
                
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
                            if ("\(item["accountBookId"]!)" == self.bookId) && (item["spendBy"] as! String == username[index-1] ){
                                print("begin  \(item["spendBy"])  \(item["theCost"])")
                                var sum = spend[index-1]
                                var new = sum + Double(item["theCost"] as! String!)!
                                spend[index-1] = new
                            }
                        }
                        
                    }
                    print(spend)
                    
                    var average = self.sum/Double(count)
                    var costlist = NSMutableArray()
                    for index in 1...count{
                        should_give.append(-(spend[index-1] - average))
                    }
                    
                    print(should_give)
                    
                    var printvar :[String] = [String]()
                    self.ShareBill.text = ""
                    for i in 1...count{
                        print("a")
                        if should_give[i-1] > 0{
                            print("b")
                            for j in 1...count{
                                
                                if should_give[j-1] < 0 && should_give[i-1] > 0 {
                                    print("c")
                                    print(should_give[j-1])
                                    print("logininname \(self.loginName)")
                                    if -(should_give[j-1]) >= should_give[i-1]{
                                        print("d")
                                        should_give[j-1] += should_give[i-1]
                                        
                                        if username[i-1] == self.loginName!{
                                            print("owner user1 \(printvar)")
                                            var box : [String] = [String]()
                                            var c = printvar.count
                                            for index in 1...c{
                                                box.append(printvar[index-1])
                                            }
                                            printvar.removeAll()
                                            print("owner user2 \(printvar)")
                                            printvar.append("\(username[i-1] ) should give \(username[j-1]) \(should_give[i-1]) \n")
                                            for index in 1...c{
                                                printvar.append(box[index-1])
                                            }
                                            print("owner user3 \(printvar)")
                                            

                                        }
                                        else{
                                            printvar.append ("\(username[i-1] ) should give \(username[j-1]) \(should_give[i-1]) \n")
                                        
                                            print("\(username[i-1] ) should give \(username[j-1]) \(should_give[i-1])" )
                                            
                                        }
                                        should_give[i-1] = 0
                                        print("afterchange \(printvar)")
                                    }
                                    else if -(should_give[j-1]) < should_give[i-1]{
                                        print("e")
                                        
                                        print(should_give[i-1])
                                        print(should_give[j-1])
                                        should_give[i-1] = should_give[i-1] + should_give[j-1]
                                        print(should_give[i-1])
                                        
                                        if username[i-1] == self.loginName!{
                                            print("owner user1 \(printvar)")
                                            var box : [String] = [String]()
                                            var c = printvar.count
                                            for index in 1...c{
                                                box.append(printvar[index-1])
                                            }
                                            printvar.removeAll()
                                            print("owner user2 \(printvar)")
                                            printvar.append("\(username[i-1] ) should give \(username[j-1]) \(-should_give[j-1])")
                                            print("\(username[i-1] ) should give \(username[j-1]) \(-should_give[j-1])" )
                                            
                                            for index in 1...c{
                                                printvar.append(box[index-1])
                                            }
                                            print("owner user3 \(printvar)")
                                            
                                            
                                        }
                                        else{
                                            printvar.append("\(username[i-1] ) should give \(username[j-1]) \(-should_give[j-1])")
                                            print("\(username[i-1] ) should give \(username[j-1]) \(-should_give[j-1])" )
                                            
                                        }
                                        
                                        
                                        
                                        
                                        
                                        
                                        print("afterchange \(printvar)")
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
        
        print("the transfer bookid is : ", self.bookId)
        
    }
    }
    
    func refreshData(_ sender: UIRefreshControl!){
        
        refresh.endRefreshing()
    }
    
    
    
    

    
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


