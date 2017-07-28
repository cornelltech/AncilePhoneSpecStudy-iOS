//
//  ANCNotificationManager.swift
//  AncilePhoneSpecStudy
//
//  Created by James Kizer on 7/27/17.
//  Copyright © 2017 smalldatalab. All rights reserved.
//

import UIKit
import UserNotifications

open class ANCNotificationManager: NSObject {
    
    static let kWeeklyNotificationIdentifer: String = "WeeklyNotification"
    
    static let kWeeklyNotificationTitle: String = "Hey 👋"
    static let kWeeklyNotificationBody: String = "It's time to take your weekly survey!"

    //the next monday at 9am
    static private func computeFireDate() -> Date? {
        
        let calendar = Calendar(identifier: .gregorian)
        debugPrint(calendar.weekdaySymbols)
        
        let now = Date()
        var components = DateComponents()
        ///matches next monday morning at 9am
//        components.weekday = 2
        components.hour = 9
        
        return calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)
        
//        return Date().addingTimeInterval(60.0)
        
    }
    
    static public func setNotifications() {
        
        //always clear notification before setting
        cancelNotifications()

        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization
            }
            
            let content = UNMutableNotificationContent()
            content.title = kWeeklyNotificationTitle
            content.body = kWeeklyNotificationBody
            
//            var components = DateComponents()
//            ///matches next monday morning at 9am
//            components.weekday = 2
//            components.hour = 9
//            
//            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24*60*60.0, repeats: true)
            
            let request = UNNotificationRequest(identifier: kWeeklyNotificationIdentifer, content: content, trigger: trigger)
            
            center.add(request) { (error : Error?) in
                if let theError = error {
                    debugPrint(theError.localizedDescription)
                }
            }
        }
        else {
            
            guard let initialFireDate = self.computeFireDate() else {
                return
            }
            
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            
            let notification = UILocalNotification()
            notification.userInfo = ["identifier": kWeeklyNotificationIdentifer]
            notification.fireDate = initialFireDate
//            notification.repeatInterval = NSCalendar.Unit.weekOfYear
            notification.repeatInterval = NSCalendar.Unit.day
            notification.alertBody = "\(kWeeklyNotificationTitle), \(kWeeklyNotificationBody)"
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }

    static public func cancelNotifications() {
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [kWeeklyNotificationIdentifer])
        }
        else {
            if let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications {
                let notificationsToCancel = scheduledNotifications.filter({ (notification) -> Bool in
                    guard let userInfo = notification.userInfo as? [String: AnyObject],
                        let identifer = userInfo["identifier"] as? String,
                        identifer == kWeeklyNotificationIdentifer else {
                            return false
                    }
                    return true
                })
                notificationsToCancel.forEach({ (notification) in
                    UIApplication.shared.cancelLocalNotification(notification)
                })
            }
        }
        
    }

}
