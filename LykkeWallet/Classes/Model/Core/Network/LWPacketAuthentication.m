//
//  LWPacketAuthentication.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketAuthentication.h"
#import "LWPersonalDataModel.h"
#import "LWKeychainManager.h"
#import "LWPrivateKeyManager.h"
#import "AppDelegate.h"
#import "LWAuthManager.h"


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
    _personalData = [[LWPersonalDataModel alloc]
                     initWithJSON:[result objectForKey:@"PersonalData"]];
    
    [[LWKeychainManager instance] saveLogin:self.authenticationData.email
                                   password:self.authenticationData.password
                                      token:_token];
    if(result[@"Pin"])
        [[LWKeychainManager instance] savePIN:result[@"Pin"]];
    
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"CanCashInViaBankCard"] boolValue] forKey:@"CanCashInViaBankCard"];
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"SwiftDepositEnabled"] boolValue] forKey:@"SwiftDepositEnabled"];
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CanCashInViaBankCard"];//Testing

    
    
    [[LWKeychainManager instance] savePersonalData:_personalData];
    if(result[@"NotificationsId"])
    {
        [[LWKeychainManager instance] saveNotificationsTag:result[@"NotificationsId"]];
        AppDelegate *tmptmp=[UIApplication sharedApplication].delegate;
        [tmptmp registerForNotificationsInAzureWithTag:result[@"NotificationsId"]];
    }
    if(result[@"EncodedPrivateKey"] && [result[@"EncodedPrivateKey"] length])
    {
        [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:result[@"EncodedPrivateKey"]];
    }
//    else
//    {
//        [[LWAuthManager instance] requestEncodedPrivateKey];
//    }
    
    
    
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
