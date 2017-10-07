/*
 This class present the accountbook id, and others can find this accountbook via the id
 */

import Foundation
import UIKit


class shareBookId: UIViewController,  UIBarPositioningDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    var bookId = ""
    var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "selectedBookId") != nil{
            bookId = UserDefaults.standard.string(forKey: "selectedBookId")!
        }
        else{
            if UserDefaults.standard.string(forKey: loginName!) != nil{
                bookId = UserDefaults.standard.string(forKey: loginName!)!
            }
        }
        label.text = "\(bookId) "
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
