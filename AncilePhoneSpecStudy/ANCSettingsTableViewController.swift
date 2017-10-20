//
//  ANCSettingsTableViewController.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 10/16/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import ResearchSuiteAppFramework
import ResearchKit

class ANCSettingsTableViewController: UITableViewController {

    @IBOutlet weak var surveyTimeCell: UITableViewCell!
    @IBOutlet weak var participantSinceCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }

    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let title = "Sign Out?"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let logoutAction = UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AppDelegate.appDelegate.signOut()
        })
        alert.addAction(logoutAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func versionString() -> String {
        
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            let config = Bundle.main.infoDictionary?["Config"] as? String
            else {
                return "Unknown Version"
        }
        
        return "\(config) Version \(version) (Build \(build))"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            
            //add logout here
            guard let reuseIdentifier = cell.reuseIdentifier else {
                return
            }
            
            print(reuseIdentifier)
            
            if reuseIdentifier == "set_survey_time" {
                
                guard let task = AppDelegate.appDelegate.activityManager.task(for: "notificationTime") else {
                    return
                }
                
                let tvc = RSAFTaskViewController(activityUUID: UUID(), task: task, taskFinishedHandler: { [weak self] (taskViewController, reason, error) in
                    
                    guard reason == ORKTaskViewControllerFinishReason.completed else {
                        self?.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    let taskResult = taskViewController.result
                    
                    print(taskResult)
                    
                    guard let stepResult = taskResult.result(forIdentifier: "notificationTime") as? ORKStepResult,
                        let timeResult = stepResult.result(forIdentifier: "notificationTime") as? ORKTimeOfDayQuestionResult,
                        let timeComponents = timeResult.dateComponentsAnswer else {
                            self?.dismiss(animated: true, completion: nil)
                            return
                    }
                    
                    
                    AppDelegate.appDelegate.store.notificationTime = timeComponents
                    
                    self?.dismiss(animated: true, completion: {
                        ANCNotificationManager.setNotifications()
                        ANCNotificationManager.printPendingNotifications()
                    })
                    
                })
                
                self.present(tvc, animated: true, completion: nil)
            }
            
            if reuseIdentifier == "launch_survey" {
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
                        AppDelegate.appDelegate.store.lastSurveyCompletionTime = Date()
                    })
                    
                })
                
                self.present(tvc, animated: true, completion: {
                    AppDelegate.appDelegate.store.lastSurveyLaunchTime = Date()
                })
            }
         
        }
    }
    
    func updateUI() {
        self.versionCell.textLabel?.text = self.versionString()
        
        if let date = AppDelegate.appDelegate.store.participantSince {
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            let dateString = formatter.string(from: date)
            self.participantSinceCell.detailTextLabel?.text = dateString
        }
        else {
            self.participantSinceCell.detailTextLabel?.text = ""
        }
        
        if let components = AppDelegate.appDelegate.store.notificationTime,
            let hour = components.hour,
            let minute = components.minute {
            
            let timeString = String(format: "%d:%.2d %@", (hour % 12 == 0) ? 12 : hour % 12, minute, (hour / 12 == 0) ? "AM" : "PM")
            print(timeString)
            self.surveyTimeCell.detailTextLabel?.text = timeString
        }
        else {
            self.surveyTimeCell.detailTextLabel?.text = ""
        }
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
