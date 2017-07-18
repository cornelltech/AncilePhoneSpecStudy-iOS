//
//  AuthTestViewController.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 7/10/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit

class AuthTestViewController: UIViewController {

    @IBOutlet weak var coreAuthButton: UIButton!
    
    var authToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.authToken = AppDelegate.appDelegate.store.get(key: ANCStore.kAncileAuthToken) as? String
        
        self.coreAuthButton.isEnabled = self.authToken != nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
//        let url: URL = (AppDelegate.appDelegate.ancileClient?.authURL)!
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        
        //Ancile Auth
        
        
        
        //Core Auth
        //Ohmage Auth
        
        
        
    }

    @IBAction func coreAuthTapped(_ sender: Any) {
        
        guard let authToken = self.authToken else {
            return
        }
        
        AppDelegate.appDelegate.ancileClient.getCoreLink(authToken: authToken) { (urlString, error) in
            
            debugPrint(urlString)
            if let err = error {
                debugPrint(err)
                return
            }
            
            if let urlString = urlString,
                let url: URL = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            
        }
    }
}
