//
//  LWAssetModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetModel.h"


@implementation LWAssetModel


#pragma mark - Root

+ (NSString *)assetByIdentity:(NSString *)identity fromList:(NSArray *)list {
    if (list && list.count > 0) {
        for (LWAssetModel *item in list) {
            if ([item.identity isEqualToString:identity]) {
                return item.name;
            }
        }
    }
    return identity; // requirement - if not found - show identity
}


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _name     = [json objectForKey:@"Name"];
        _accuracy = [json objectForKey:@"Accuracy"];
        _symbol   = [json objectForKey:@"Symbol"];
        _hideDeposit=[[json objectForKey:@"HideDeposit"] boolValue];
        _hideWithdraw=[[json objectForKey:@"HideWithdraw"] boolValue];
    }
    return self;
}

@end
