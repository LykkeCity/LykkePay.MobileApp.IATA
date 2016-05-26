//
//  LWAssetPairRateModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetPairRateModel.h"


@implementation LWAssetPairRateModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self && ![json isKindOfClass:[NSNull class]]) {
        _identity    = [json objectForKey:@"Id"];
        _bid         = [json objectForKey:@"Bid"];
        _ask         = [json objectForKey:@"Ask"];
        _pchng       = [json objectForKey:@"PChng"];
        _expTimeout  = [json objectForKey:@"ExpTimeOut"];
        _lastChanges = [json objectForKey:@"ChngGrph"];
    }
    return self;
}

@end
