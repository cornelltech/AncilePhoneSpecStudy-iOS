//
//  ANCStore.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 7/10/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import OhmageOMHSDK
import ResearchSuiteTaskBuilder
import ResearchSuiteAppFramework

class ANCStore: NSObject, OhmageOMHSDKCredentialStore, RSTBStateHelper, OhmageManagerProvider {
    
    static public let kAncileAuthToken = "ancile_study_server_auth_token"

    func valueInState(forKey: String) -> NSSecureCoding? {
        return self.get(key: forKey)
    }
    
    func setValueInState(value: NSSecureCoding?, forKey: String) {
        self.set(value: value, key: forKey)
    }
    
    func set(value: NSSecureCoding?, key: String) {
        RSAFKeychainStateManager.setValueInState(value: value, forKey: key)
    }
    func get(key: String) -> NSSecureCoding? {
        return RSAFKeychainStateManager.valueInState(forKey: key)
    }
    
    func getOhmageManager() -> OhmageOMHManager? {
        return (UIApplication.shared.delegate as? AppDelegate)?.ohmageManager
    }
    
    func reset() {
        RSAFKeychainStateManager.clearKeychain()
    }
    
}
