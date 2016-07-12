//
//  LWPacketAuthentication.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketAuthentication.h"
#import "LWPersonalData.h"
#import "LWKeychainManager.h"
#import "AppDelegate.h"


@implementation LWPacketAuthentication


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _token = result[@"Token"];
    _status = result[@"KycStatus"];
    _isPinEntered = [result[@"PinIsEntered"] boolValue];
    _personalData = [[LWPersonalData alloc]
                     initWithJSON:[result objectForKey:@"PersonalData"]];
    
    [[LWKeychainManager instance] saveLogin:self.authenticationData.email
                                   password:self.authenticationData.password
                                      token:_token];
    
    
    [[LWKeychainManager instance] savePersonalData:_personalData];
    if(response[@"Result"][@"NotificationsId"])
    {
        [[LWKeychainManager instance] saveNotificationsTag:response[@"Result"][@"NotificationsId"]];
        AppDelegate *tmptmp=[UIApplication sharedApplication].delegate;
        [tmptmp registerForNotificationsInAzureWithTag:response[@"Result"][@"NotificationsId"]];
    }
    
}

- (NSString *)urlRelative {
    return @"Auth";
}

- (NSDictionary *)params {
    return @{@"Email" : self.authenticationData.email,
             @"Password" : self.authenticationData.password,
             @"ClientInfo" : self.authenticationData.clientInfo};
//             @"AppVersion" : [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]};
//    @"AppVersion" : @"222"};
}

@end
