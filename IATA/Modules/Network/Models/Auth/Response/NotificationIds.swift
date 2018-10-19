//
//  NotificationIds.swift
//  IATA
//
//  Created by Alexei Lazarev on 7/6/18.
//  Copyright © 2018 Елизавета Казимирова. All rights reserved.
//

import ObjectMapper

class NotificationIds: Mappable {

    private enum PropertyKey: String {
        case aps
    }

    internal var IDs: [String]?

    internal required init?(map: Map) {
    }

    internal func mapping(map: Map) {
        IDs <- map[PropertyKey.aps.rawValue]
    }
}
