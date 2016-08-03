//
//  LWPacketAPIVersion.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketApplicationInfo.h"

@implementation LWPacketApplicationInfo


- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    self.apiVersion=result[@"AppVersion"];
    
    
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return @"ApplicationInfo";
}

@end
