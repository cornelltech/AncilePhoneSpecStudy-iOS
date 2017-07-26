//
//  ANCOnboardingViewController.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 7/10/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss

open class ANCOnboardingViewController: UIViewController {
    
    var eligible = false
    var consented = false
    var authenticated = false
    var notificationSet = false

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
//        let url: URL = (AppDelegate.appDelegate.client?.authURL)!
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        self.launchActivity()
        
    }
    
    func chooseActivity() -> String? {
        if !eligible {
            return "eligibility"
        }
    
        return "authFlow"
    }
    
    func launchActivity() {
        
        if !eligible {
            
            guard let task = AppDelegate.appDelegate.activityManager.task(for: "eligibility") else {
                return
            }
            
            let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
                
                guard reason == ORKTaskViewControllerFinishReason.completed else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                
                let taskResult = taskViewController.result
                
                guard let stepResult = taskResult.result(forIdentifier: "eligibility") as? ORKStepResult,
                    let ageResult = stepResult.result(forIdentifier: "age") as? ORKBooleanQuestionResult,
                    let eligible = ageResult.booleanAnswer?.boolValue else {
                        self?.dismiss(animated: true, completion: nil)
                        return
                }
                
                self?.eligible = eligible
                self?.dismiss(animated: true, completion: {
                    if eligible {
                        self?.launchActivity()
                    }
                })
                
            })
            
            self.present(tvc, animated: true, completion: nil)
        }
        else if !consented {
            
            guard let task = self.consentTask() else {
                return
            }
            
            let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
                
                guard reason == ORKTaskViewControllerFinishReason.completed else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                
                let taskResult = taskViewController.result
                
                guard let stepResult = taskResult.result(forIdentifier: "consentReviewStep") as? ORKStepResult,
                    let consentSignature = stepResult.firstResult as? ORKConsentSignatureResult else {
                        self?.dismiss(animated: true, completion: nil)
                        return
                }
                
                self?.consented = consentSignature.consented
                
                self?.dismiss(animated: true, completion: {
                    if consentSignature.consented {
                        self?.launchActivity()
                    }
                })
                
                
                
            })
            
            self.present(tvc, animated: true, completion: nil)
            
        }
        
        else if !authenticated {
            
            guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate),
                let ohmageClient = appDelegate.ohmageManager else {
                    return
            }
            
            ohmageClient.signOut(completion: { (error) in
                
                guard let task = AppDelegate.appDelegate.activityManager.task(for: "authFlow") else {
                    return
                }
                
                let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
                    
                    guard reason == ORKTaskViewControllerFinishReason.completed else {
                        self?.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    let taskResult = taskViewController.result
                    
                    //                guard let stepResult = taskResult.result(forIdentifier: "eligibility") as? ORKStepResult,
                    //                    let ageResult = stepResult.result(forIdentifier: "age") as? ORKBooleanQuestionResult,
                    //                    let eligible = ageResult.booleanAnswer?.boolValue else {
                    //                        self?.dismiss(animated: true, completion: nil)
                    //                        return
                    //                }
                    //
                    //                self?.eligible = eligible
                    
                    self?.authenticated = true
                    
                    if let consented = self?.consented,
                        let appDelegate = (UIApplication.shared.delegate as? AppDelegate),
                        let authToken = appDelegate.ancileClient.authToken {
                        if consented {
                            appDelegate.ancileClient.postConsent(token: authToken, completion: { (consented, error) in
                                
                            })
                        }
                        
                    }
                    
                    self?.dismiss(animated: true, completion: {
                        
                        self?.launchActivity()
                    })
                    
                })
                
                self.present(tvc, animated: true, completion: nil)
                
            })
            
            
        }
        else if !notificationSet {
            guard let task = AppDelegate.appDelegate.activityManager.task(for: "notificationTime") else {
                return
            }
            
            let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
                
                guard reason == ORKTaskViewControllerFinishReason.completed else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                
                self?.notificationSet = true
                self?.dismiss(animated: true, completion: {
                    self?.launchActivity()
                })
                
            })
            
            self.present(tvc, animated: true, completion: nil)
        }
        else {
            
            guard let task = AppDelegate.appDelegate.activityManager.task(for: "weeklySurvey"),
                let activity = AppDelegate.appDelegate.activityManager.activity(for: "weeklySurvey") else {
                return
            }
            
            let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
                
                guard reason == ORKTaskViewControllerFinishReason.completed else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                
                let taskResult = taskViewController.result
                
                AppDelegate.appDelegate.resultsProcessor.processResult(taskResult: taskResult, resultTransforms: activity.resultTransforms)

                self?.dismiss(animated: true, completion: {
                })
                
            })
            
            self.present(tvc, animated: true, completion: nil)
            
        }
        
        
    }
    
    func consentTask() -> ORKTask? {
//        let consentDocument = ANCConsentDocument()
        
        guard let consentDocumentJSON = AppDelegate.appDelegate.taskBuilder.helper.getJson(forFilename: "consentDocument") as? JSON,
            let consentDocType: String = "type" <~~ consentDocumentJSON,
            let consentDocument = AppDelegate.appDelegate.taskBuilder.generateConsentDocument(
                type: consentDocType, jsonObject: consentDocumentJSON, helper: AppDelegate.appDelegate.taskBuilder.helper) else {
                    return nil
        }
        
        let visualConsentStep = ORKVisualConsentStep(identifier: "visualConsentStep", document: consentDocument)
        
        guard let signature = consentDocument.signatures?.first else {
            return nil
        }
        
        let reviewConsentStep = ORKConsentReviewStep(identifier: "consentReviewStep", signature: signature, in: consentDocument)
        
        // In a real application, you would supply your own localized text.
        reviewConsentStep.text = "Consent Review"
        reviewConsentStep.reasonForConsent = "You need to consent"
        
        return ORKOrderedTask(identifier: "consentTask", steps: [
            visualConsentStep,
            reviewConsentStep
            ])
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
