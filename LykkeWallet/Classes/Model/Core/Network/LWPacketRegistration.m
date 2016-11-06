//
//  LWPacketRegistration.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 11.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketRegistration.h"
#import "LWKeychainManager.h"


@implementation LWPacketRegistration


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _token = result[@"Token"];
    
    [[LWKeychainManager instance] saveLogin:self.registrationData.email
                                      token:_token];
}

- (NSString *)urlRelative {
    return @"Registration";
}

- (NSDictionary *)params {
    return @{@"Email" : self.registrationData.email,
             //@"FullName" : self.registrationData.fullName,
             //@"ContactPhone" : self.registrationData.phone,
             @"Password" : self.registrationData.password,
             @"ClientInfo" : self.registrationData.clientInfo};
}

@end
