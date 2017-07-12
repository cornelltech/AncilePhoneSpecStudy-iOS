//
//  AppDelegate.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 6/22/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import OhmageOMHSDK
import ResearchSuiteTaskBuilder
import ResearchSuiteResultsProcessor
import ResearchSuiteAppFramework
import Gloss
import sdlrkx

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ancileClient: AncileStudyServerClient!
    
    var store: ANCStore!
    var ohmageManager: OhmageOMHManager!
    var taskBuilder: RSTBTaskBuilder!
    var resultsProcessor: RSRPResultsProcessor!
    var activityManager: ANCActivityManager!
    
    func initializeOhmage(credentialsStore: OhmageOMHSDKCredentialStore) -> OhmageOMHManager {
        
        //load OMH client application credentials from OMHClient.plist
        guard let file = Bundle.main.path(forResource: "OMHClient", ofType: "plist") else {
            fatalError("Could not initialze OhmageManager")
        }
        
        
        let omhClientDetails = NSDictionary(contentsOfFile: file)
        
        guard let baseURL = omhClientDetails?["OMHBaseURL"] as? String,
            let clientID = omhClientDetails?["OMHClientID"] as? String,
            let clientSecret = omhClientDetails?["OMHClientSecret"] as? String else {
                fatalError("Could not initialze OhmageManager")
        }
        
        if let ohmageManager = OhmageOMHManager(baseURL: baseURL,
                                                clientID: clientID,
                                                clientSecret: clientSecret,
                                                queueStorageDirectory: "ohmageSDK",
                                                store: credentialsStore) {
            return ohmageManager
        }
        else {
            fatalError("Could not initialze OhmageManager")
        }
        
    }
    
    
    static var appDelegate: AppDelegate! {
        return UIApplication.shared.delegate! as! AppDelegate
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.ancileClient = AncileStudyServerClient(baseURL: "https://ancile.cornelltech.io")
//        self.ohmageManager = self.initializeOhmage(credentialsStore: self.store)
        
        self.store = ANCStore()
        
        self.taskBuilder = RSTBTaskBuilder(
            stateHelper: self.store,
            elementGeneratorServices: AppDelegate.elementGeneratorServices,
            stepGeneratorServices: AppDelegate.stepGeneratorServices,
            answerFormatGeneratorServices: AppDelegate.answerFormatGeneratorServices
        )
        
//        self.resultsProcessor = RSRPResultsProcessor(
//            frontEndTransformers: AppDelegate.resultsTransformers,
//            backEnd: ORBEManager(ohmageManager: self.ohmageManager)
//        )
        
        self.activityManager = ANCActivityManager(activityFilename: "activities", taskBuilder: self.taskBuilder)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let code = self.getQueryStringParameter(url: url.absoluteString, param: "code") {
            self.ancileClient.signIn(code: code) { (signInResponse, error) in
                
                debugPrint(signInResponse)
                if let err = error {
                    debugPrint(err)
                    return
                }
                
                if let response = signInResponse {
                    self.store.set(value: response.authToken as NSSecureCoding, key: ANCStore.kAncileAuthToken)
                }
//
//                self.reachabilityManager.startListening()
//                self.oauthCompletion?(nil)
                
            }
        }
        
        return true
    }
    
    
    open class var stepGeneratorServices: [RSTBStepGenerator] {
        return [
            CTFOhmageLoginStepGenerator(),
            CTFDelayDiscountingStepGenerator(),
            CTFBARTStepGenerator(),
            RSTBInstructionStepGenerator(),
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBDecimalStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBFormStepGenerator(),
            RSTBDatePickerStepGenerator(),
            RSTBSingleChoiceStepGenerator(),
            RSTBMultipleChoiceStepGenerator(),
            RSTBBooleanStepGenerator(),
            RSTBPasscodeStepGenerator(),
            RSTBScaleStepGenerator(),
            YADLFullStepGenerator(),
            YADLSpotStepGenerator()
        ]
    }
    
    open class var answerFormatGeneratorServices:  [RSTBAnswerFormatGenerator] {
        return [
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBDecimalStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBDatePickerStepGenerator(),
            RSTBBooleanStepGenerator(),
            RSTBScaleStepGenerator()
        ]
    }
    
    open class var elementGeneratorServices: [RSTBElementGenerator] {
        return [
            RSTBElementListGenerator(),
            RSTBElementFileGenerator(),
            RSTBElementSelectorGenerator()
        ]
    }
    
    open class var resultsTransformers: [RSRPFrontEndTransformer.Type] {
        return [
            CTFBARTSummaryResultsTransformer.self,
            CTFDelayDiscountingRawResultsTransformer.self,
            YADLSpotRaw.self,
            YADLFullRaw.self
        ]
    }


}

