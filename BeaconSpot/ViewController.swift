

import UIKit
import QuartzCore
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var btnSwitchSpotting: UIButton!
    
    @IBOutlet weak var lblBeaconReport: UILabel!
    
    @IBOutlet weak var lblBeaconDetails: UILabel!
    
    
    var beaconRegion: CLBeaconRegion!
    var locationManager : CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon! = nil;
    var lastProximity : CLProximity! = CLProximity.Unknown
    let customerId = 1;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lblBeaconDetails.hidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = NSUUID(UUIDString: "A1E9FDF0-4FEA-4D4F-BA1E-636391E5C937")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "com.foodymon.demo")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mySegue1") {
            if let destination = segue.destinationViewController as? RetailViewController {
                destination.viaSegue = lastFoundBeacon;
            }
        }
    }
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.hidden = false
    }
    
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state == CLRegionState.Inside {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.hidden = true
    }

    func disconnectCustomer(beacon : CLBeacon) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://key-phoenix-95604.appspot.com/myApp/customer/" + String(customerId)+"/disconnect/"+String(beacon.major.intValue))!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error ->Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
        })
        
        task.resume()
    }
    func connectCustomer(beacon : CLBeacon) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://key-phoenix-95604.appspot.com/myApp/customer/" + String(customerId)+"/connect/"+String(beacon.major.intValue))!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error ->Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
        })
        
        task.resume()
    
    }
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {

        if beacons.count == 0 {
            if (lastFoundBeacon != nil) {
                disconnectCustomer(lastFoundBeacon);
                lastFoundBeacon = nil;
                lblBeaconDetails.hidden = true;
            }
        } else {
            let closestBeacon = beacons[0];
            lblBeaconDetails.hidden = false;
            if (lastFoundBeacon === nil || closestBeacon.major !== lastFoundBeacon.major || lastProximity != closestBeacon.proximity) {
                
                var proximityMessage: String!
                switch closestBeacon.proximity {
                case CLProximity.Immediate:
                    proximityMessage = "Very close"
                    
                case CLProximity.Near:
                    proximityMessage = "Near"
                    
                case CLProximity.Far:
                    proximityMessage = "Far"
                            
                default:
                    proximityMessage = "Where's the beacon?"
                }
                
                lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.intValue) + "\nMinor = " + String(closestBeacon.minor.intValue) + "\nDistance: " + proximityMessage

                if(lastFoundBeacon == nil) {
                    connectCustomer(closestBeacon);
                } else if(closestBeacon.major != lastFoundBeacon.major) {//a change of retailer detected
                    disconnectCustomer(lastFoundBeacon);
                    connectCustomer(closestBeacon);
                }
                lastFoundBeacon = closestBeacon;
                lastProximity = closestBeacon.proximity;
            }
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print(error)
    }
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(sender: AnyObject) {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Deactivate", forState: UIControlState.Normal)
            lblBeaconReport.text = "Searching for retailers..."
        } else {
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Activate", forState: UIControlState.Normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.hidden = true
            if(lastFoundBeacon != nil){
                disconnectCustomer(lastFoundBeacon);
                lastFoundBeacon = nil;
            }
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }

}

