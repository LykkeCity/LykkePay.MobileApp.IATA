//
//  LWPacketPinSecuritySet.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketPinSecuritySet.h"


@implementation LWPacketPinSecuritySet


#pragma mark - LWPacket

- (NSString *)urlRelative {
//    return @"PinSecurity";
    return @"PinSecurity";
}

- (NSDictionary *)params {
//    return @{@"Pin" : self.pin};
    NSDictionary *params=@{@"Pin":self.pin};
    
    return params;
}

@end

