//
//  LWAuthorizePacket.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 14.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"
#import "LWKeychainManager.h"


@implementation LWAuthorizePacket


#pragma mark - LWPacket

- (NSDictionary *)headers {
    NSString *token = [LWKeychainManager instance].token;
    
    if (token) {
        return @{@"Authorization" : [NSString stringWithFormat:@"Bearer %@", token]};
    }
    return [super headers];
}

@end
