//
//  ANCOpenURLManager.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 7/17/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import ResearchSuiteExtensions

open class ANCOpenURLManager: NSObject {
    
    
    
    var openURLDelegates: [RSOpenURLDelegate]
    
    public init(
        openURLDelegates: [RSOpenURLDelegate]?
        ) {
        self.openURLDelegates = openURLDelegates ?? []
        super.init()
    }
    
    open func handleURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let delegates = self.openURLDelegates
        for delegate in delegates {
            let handled = delegate.handleURL(app: app, url: url, options: options)
            if handled { return true }
        }
        return false
    }
    
    public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    public static func safeOpenURL(url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }

}
