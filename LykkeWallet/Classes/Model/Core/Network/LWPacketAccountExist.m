//
//  LWPacketAccountExist.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 10.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPacketAccountExist.h"
#import "LWCache.h"


@implementation LWPacketAccountExist


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    _isRegistered = [result[@"IsRegistered"] boolValue];
    _hasHint=[result[@"HasPwdHint"] boolValue];
    [LWCache instance].passwordIsHashed=[result[@"IsPwdHashed"] boolValue];
    [[NSUserDefaults standardUserDefaults] setBool:[result[@"HasBackup"] boolValue] forKey:@"UserHasBackupOfPrivateKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSString *)urlRelative {
    return @"ClientState";
}

- (NSDictionary *)params {
    return @{@"email" : self.email};
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
