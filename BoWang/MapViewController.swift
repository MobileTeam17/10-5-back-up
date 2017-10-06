//
//  ViewController.swift
//  MapKitTutorial
//
//  Created by Robert Chen on 12/23/15.
//  Copyright © 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import AVFoundation
import Firebase
import FirebaseDatabase


protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class MapViewController : UIViewController{
    
    var selectedPin:MKPlacemark? = nil
    
    var ref: DatabaseReference?
    
    let locationManager = CLLocationManager()
    var loginName = UserDefaults.standard.string(forKey: "userRegistEmail")
    var theconnector = ""
    var telephone = ""
    
    @IBOutlet weak var locationInfo: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    var addressString = ""
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.string(forKey: "theconnector") != nil){
            var theconnector = UserDefaults.standard.string(forKey: "theconnector")
            print("the connector is", self.theconnector)
            
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
        locationManager.startUpdatingLocation()
        definesPresentationContext = true
        //locationManager.stopUpdatingLocation()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client = delegate.client
        var itemTable = client.table(withName: "login")
        
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    print("bbbbbbbbb", "\(item["email"]!)")
                    if "\(item["email"]!)" == self.loginName{
                        self.telephone = "\(item["telephone"]!)"
                        print("the fffffff is", self.theconnector)
                        print("the phone is", self.telephone)
                    }
                }
            }
        }
        
    }
    
    
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
            map.setRegion(region, animated: true)
            print(location.altitude)
            print(location.speed)
            self.map.showsUserLocation = true
            
            
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                print(location)
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0] as! CLPlacemark
                    
                    //print(pm.subThoroughfare)
                    //print(pm.thoroughfare)
                    //print(pm.locality)
                    //print(pm.subLocality)
                    //print(pm.country)
                    //print(pm.postalCode)
                    
                    
                    self.addressString = ""
                    if pm.subLocality != nil {
                        self.addressString = self.addressString + pm.subLocality! + ", "
                    }
                    if pm.subThoroughfare != nil {
                        self.addressString = self.addressString + pm.subThoroughfare! + " "
                    }
                    if pm.thoroughfare != nil {
                        self.addressString = self.addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        self.addressString = self.addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        self.addressString = self.addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        self.addressString = self.addressString + pm.postalCode! + " "
                    }
                    
                    
                    print(self.addressString)
                    self.locationInfo.text = self.addressString
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}



extension MapViewController: UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate{
    //UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
    //becomeFirstResponder()
    
    //override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let fromId = loginName
        let ref = Database.database().reference().child("message")
        var values = [String:Any]()
        if (addressString != "") {
            values = ["text": addressString,"fromId":fromId,"toId":theconnector]
            print("fffffffffffff", values)
            
            ref.updateChildValues(values)
        }
        
        
        //set up the connector
        let str = self.theconnector
        //create a window to inform the user
        let alertController = UIAlertController(title: "send message", message: "Do you want to send message to \(str) ?", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let sendAction = UIAlertAction(title: "yes", style: .default) { (alertController) in
            //to judge whether the device can send message
            if MFMessageComposeViewController.canSendText() {
                let controller = MFMessageComposeViewController()
                //the content of the message
                let str = "Hi, I am " + fromId!
                let str2 = "\(str)  Now, I am in:  \(self.addressString) "
                controller.body = "\(str)  Now, I am in:  \(self.addressString) "
                //connection list
                controller.recipients = [self.telephone]
                //set up the agent
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                print("the phone cannot send message")
            }
        }
        alertController.addAction(cancleAction)
        alertController.addAction(sendAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    //实现MFMessageComposeViewControllerDelegate的代理方法
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        //判断短信的状态
        switch result{
            
        case .sent:
            print("the message has been sent")
        case .cancelled:
            print("the message has been cancelled")
        case .failed:
            print("the message is failed to send")
        default:
            print("the message has been send successfully")
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MapViewController: AVAudioPlayerDelegate {
    
    
    
    /**
     begin shake
     */
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        /**
         set up the sensor
         */
        UIApplication.shared.applicationSupportsShakeToEdit = true
        becomeFirstResponder()
        print("start to shake")
        
        let fromId = loginName
        let ref = Database.database().reference().child("message")
        var values = [String:Any]()
        if (addressString != "") {
            values = ["text": addressString,"fromId":fromId,"toId":theconnector]
            print("fffffffffffff" + fromId!)
            ref.updateChildValues(values)
        }
        
        /// set up the music
        let path1 = Bundle.main.path(forResource: "rock", ofType:"mp3")
        let data1 = try? Data(contentsOf: URL(fileURLWithPath: path1!))
        self.player = try? AVAudioPlayer(data: data1!)
        self.player?.delegate = self
        self.player?.updateMeters()//renew the data
        self.player?.prepareToPlay()//prepare the data
        self.player?.play()
        
        print("bowangtest",ref.database.reference().child("message"))
        
        //set up the connector
        let str = self.theconnector
        //create a window to inform the user
        let alertController = UIAlertController(title: "send message", message: "Do you want to send message to \(str) ?", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        let sendAction = UIAlertAction(title: "yes", style: .default) { (alertController) in
            //to judge whether the device can send message
            if MFMessageComposeViewController.canSendText() {
                let controller = MFMessageComposeViewController()
                //the content of the message
                let str = "Hi, I am " + fromId!
                let str2 = "\(str)  Now, I am in:  \(self.addressString) "
                controller.body = "\(str)  Now, I am in:  \(self.addressString) "
                //connection list
                controller.recipients = [self.telephone]
                print("gggggggggggggggggg",self.telephone)
                //set up the agent
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                print("the phone cannot send message")
            }
        }
        alertController.addAction(cancleAction)
        alertController.addAction(sendAction)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
}
