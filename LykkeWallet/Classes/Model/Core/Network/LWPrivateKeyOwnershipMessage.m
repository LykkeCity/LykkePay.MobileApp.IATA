//
//  LWPrivateKeyOwnershipMessage.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateKeyOwnershipMessage.h"

@implementation LWPrivateKeyOwnershipMessage

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.ownershipMessage=result[@"Message"];
    
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"PrivateKeyOwnershipMsg?email=%@", self.email];
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
