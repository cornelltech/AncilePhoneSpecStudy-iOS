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

open class ANCOnboardingViewController: UIViewController {
    
    var eligible = false

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
    
        return nil
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
