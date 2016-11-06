//
//  LWNetAccessor.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 13.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWNetAccessor.h"


@implementation LWNetAccessor


#pragma mark - Common

- (void)sendPacket:(LWPacket *)packet {
    [self sendPacket:packet info:nil];
}

- (void)sendPacket:(LWPacket *)packet info:(NSDictionary *)userInfo {
    [[GDXNet instance] send:packet userInfo:userInfo method:GDXNetSendMethodREST];
}

@end
