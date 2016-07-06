//
//  LWPacketRegistration.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 11.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketRegistration.h"
#import "LWKeychainManager.h"
#import "AppDelegate.h"


@implementation LWPacketRegistration


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _token = result[@"Token"];
    
    [[LWKeychainManager instance] saveLogin:self.registrationData.email
                                password:self.registrationData.password
                                      token:_token];
    
    if(response[@"Result"][@"NotificationsId"])
    {
        AppDelegate *tmptmp=[UIApplication sharedApplication].delegate;
        [tmptmp registerForNotificationsInAzureWithTag:response[@"Result"][@"NotificationsId"]];
    }

}

- (NSString *)urlRelative {
    return @"Registration";
}

- (NSDictionary *)params {
    return @{@"Email" : self.registrationData.email,
             //@"FullName" : self.registrationData.fullName,
             //@"ContactPhone" : self.registrationData.phone,
             @"Password" : self.registrationData.password,
             @"ClientInfo" : self.registrationData.clientInfo,
             @"Hint":self.registrationData.passwordHint};
}

@end
