//
//  LWEncodedPrivateKeyGet.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWEncodedPrivateKeyGet.h"
#import "LWKeychainManager.h"
#import "LWPrivateKeyManager.h"

@implementation LWEncodedPrivateKeyGet

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    if(response[@"Result"][@"EncodedPrivateKey"])
    {
        [[LWKeychainManager instance] saveEncodedPrivateKey:response[@"Result"][@"EncodedPrivateKey"]];
        
        [[LWPrivateKeyManager shared] decryptKeyIfPossible];
        
    }
    
    
}

-(NSDictionary *) params
{
    NSDictionary *params=@{@"Password":[LWKeychainManager instance].password, @"Pin":[LWKeychainManager instance].pin};
     return params;
}


- (NSString *)urlRelative {
    return @"EncodedPrivateKey";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypePOST;
}


@end
