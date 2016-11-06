//
//  LWPacketGraphPeriodsGet.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@interface LWPacketGraphPeriodsGet : LWAuthorizePacket {
    
}
// out
// Array of LWGraphPeriodModel
@property (strong, nonatomic) NSArray *graphPeriods;

@end
