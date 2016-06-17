//
//  LWPacketSetRefundAddress.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketSetRefundAddress.h"

@implementation LWPacketSetRefundAddress

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"Address":self.refundAddress};
    return params;
}


- (NSString *)urlRelative {
    return @"RefundAddress";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}


@end
