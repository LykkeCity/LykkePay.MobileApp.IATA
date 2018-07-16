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
    static let prod = PushNotificationHubSettings(name: "lykke-notifications",
                                                        listenAccess: "Endpoint=sb://pay-notifications.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=s3wAOMhtQp2P54Key83EIOghQAafH3Aw1+QZho76Ias=")

    static let dev = PushNotificationHubSettings(name: "lykkepay-notifications-dev",
                                                 listenAccess: "Endpoint=sb://lykkepay-dev.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=LYPQRkb7PTRtw6UgbTn0dRSZSAHELaMdybTVb7dWlz4=")
}


