/*
 This class is the map page
 1. We present a map
 2. We can get our current location and present as text at the bottom
 3. We can tap the screen or shake the photo to send a message( it's a knid of sensor)
 4. Most of the information is already edited in advance, just need emergency contact number
 */

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

    //map and location
    @IBOutlet weak var locationInfo: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var addressString = ""
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("the connector isswwwwwww", UserDefaults.standard.string(forKey: "theconnector"))
        if (UserDefaults.standard.string(forKey: "theconnector") != nil){
            theconnector = UserDefaults.standard.string(forKey: "theconnector")!
            print("the connector is", self.theconnector)
            
        }
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        definesPresentationContext = true
        
        //read the 'telephone' and 'emergency contact' from the login table, and they will be used in sending message function
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let client = delegate.client
        var itemTable = client.table(withName: "login")
        itemTable.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if "\(item["email"]!)" == self.loginName{
                        self.telephone = "\(item["telephone"]!)"
                    }
                }
            }
        }
        if (UserDefaults.standard.string(forKey: "theconnector") != nil){
            var theconnector = UserDefaults.standard.string(forKey: "theconnector")!
            print("the connector is", self.theconnector)
            
        }
    }
}


extension MapViewController : CLLocationManagerDelegate {
    
    //change address
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    //get address
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            //get the current speed and altitude
            //basic set up
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
            map.setRegion(region, animated: true)
            print("the user location altitude", location.altitude)
            print("the user spped altitude", location.speed)
            self.map.showsUserLocation = true
            
            //get the placemark
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                print(location)
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                //get the address datial from placemark, which incloud city, country, state, street, postcode and so on
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0] as! CLPlacemark
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
    
    //get the error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}



extension MapViewController: UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let fromId = loginName
        let ref = Database.database().reference().child("message")
        var values = [String:Any]()
        if (addressString != "") {
            values = ["text": addressString,"fromId":fromId,"toId":self.theconnector]
            ref.updateChildValues(values)
        }
        
        //set up the connector
        let str = self.theconnector
        //create a window to inform the user
        let alertController = UIAlertController(title: "send message", message: "Do you want to send message to \(theconnector) ?", preferredStyle: .alert)
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
    //Here we implement the 'MFMessageComposeViewControllerDelegate' method
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
        //get the state of the message
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
            ref.updateChildValues(values)
        }
        
        //set up the connector
        let str = self.theconnector
        
        // set up the music
        let path1 = Bundle.main.path(forResource: "rock", ofType:"mp3")
        let data1 = try? Data(contentsOf: URL(fileURLWithPath: path1!))
        self.player = try? AVAudioPlayer(data: data1!)
        self.player?.delegate = self
        
        //renew the data
        self.player?.updateMeters()
        
        //prepare the data
        self.player?.prepareToPlay()
        self.player?.play()
        
        //create a window to inform the user
        let alertController = UIAlertController(title: "send message", message: "Do you want to send message to \(theconnector) ?", preferredStyle: .alert)
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
}
