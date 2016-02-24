//
//  RetailViewController.swift
//  FoodyMon Demo
//
//  Created by Grace You on 2015-12-13.
//  Copyright © 2015 FoodyMon. All rights reserved.
//

import UIKit
import CoreLocation

class RetailViewController: UIViewController {

    @IBOutlet var myWebView: UIWebView!
    var viaSegue : CLBeacon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = NSURL (string: "https://key-phoenix-95604.appspot.com/clientSrc/#/customer/1");
        let requestObj = NSURLRequest(URL: url!);
        myWebView.loadRequest(requestObj);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
