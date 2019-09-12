//
//  NotificationManager.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UserNotifications
import UIKit

class NotificationManager {
    
    static func notification() -> NotificationManager {
        return NotificationManager()
    }
    static var deviceToken: String? {
        get {
            return UserDefaultsManager.deviceToken
        }
        set {
            if newValue != UserDefaultsManager.deviceToken {
                //send to server
                //NewUserController.sharedInstance.remote(oldToken: UserDefaultsManager.deviceToken, newToken: newValue!, businessId: UserDefaultsManager.businessId!)
            }
            UserDefaultsManager.deviceToken = newValue
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}
