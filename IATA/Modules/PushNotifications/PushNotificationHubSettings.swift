//
//  PushNotificationHubSettings.swift
//  IATA
//
//  Created by Alexei Lazarev on 7/6/18.
//  Copyright © 2018 Елизавета Казимирова. All rights reserved.
//

import Foundation

struct PushNotificationHubSettings {
    let name: String
    let listenAccess: String
}

extension PushNotificationHubSettings {
//    static let production = PushNotificationHubSettings(name: "lykke-notifications",
//                                                        listenAccess: "Endpoint=sb://lykkewallet.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=XwEA5pk9uDLkZXgnZF5sdDrZYEx5eoaE7LFlLoy+wh4=")

    static let dev = PushNotificationHubSettings(name: "lykkepay-notifications-dev",
                                                 listenAccess: "Endpoint=sb://lykkepay-dev.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=LYPQRkb7PTRtw6UgbTn0dRSZSAHELaMdybTVb7dWlz4=")
}


