//
//  LWPacketGetRefundAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGetRefundAddress.h"

@implementation LWPacketGetRefundAddress

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.refundAddress=response[@"Result"][@"Address"];
    
}

- (NSString *)urlRelative {
    return @"RefundAddress";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
