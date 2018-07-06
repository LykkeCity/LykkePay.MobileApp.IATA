//
//  PushNotificationHelper.swift
//  IATA
//
//  Created by Alexei Lazarev on 7/6/18.
//  Copyright © 2018 Елизавета Казимирова. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class PushNotificationHelper: NSObject {

    static var token: Data?

    @objc class func register(with application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (isGranted, error) in
                if isGranted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }

    @objc class func application(_ application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }

    @objc class func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        self.token = token
    }

    @objc class func registerInAzureHUB(with notificationTags: [String]?) {
        guard let notificationTags = notificationTags,
            let token = self.token else {
                return
        }
        DispatchQueue.main.async {
            let hubSettings = NetworkConfig.shared.notificationHubSettings
            let hub = SBNotificationHub(connectionString: hubSettings.listenAccess, notificationHubPath: hubSettings.name)
            hub?.registerNative(withDeviceToken: token, tags: Set(notificationTags), completion: { (_) in

            })
        }
    }

    @objc class func unregisterInAzureHUB() {
        let hubSettings = NetworkConfig.shared.notificationHubSettings
        let hub = SBNotificationHub(connectionString: hubSettings.listenAccess, notificationHubPath: hubSettings.name)
        hub?.unregisterNative(completion: {_ in })
    }

}
