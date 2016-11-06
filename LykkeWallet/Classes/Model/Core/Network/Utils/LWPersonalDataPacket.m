//
//  LWPersonalDataPacket.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPersonalDataPacket.h"
#import "LWPersonalData.h"
#import "LWKeychainManager.h"


@implementation LWPersonalDataPacket {
    
}


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    _personalData = [[LWPersonalData alloc]
                     initWithJSON:[result objectForKey:@"PersonalData"]];
    [[LWKeychainManager instance] savePersonalData:_personalData];
}

@end
