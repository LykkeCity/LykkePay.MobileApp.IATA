//
//  LWPacketGraphRates.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"


@class LWGraphPeriodRatesModel;


@interface LWPacketGraphRates : LWAuthorizePacket {
    
}
// in
@property (copy, nonatomic) NSString *period;
@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSNumber *points;
// out
@property (strong, nonatomic) LWGraphPeriodRatesModel *data;

@end
