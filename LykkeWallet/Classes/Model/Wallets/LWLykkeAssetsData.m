//
//  LWLykkeAssetsData.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWLykkeAssetsData.h"


@implementation LWLykkeAssetsData {
    
}


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity    = [json objectForKey:@"Id"];
        _name        = [json objectForKey:@"Name"];
        _symbol      = [json objectForKey:@"Symbol"];
        _balance     = [json objectForKey:@"Balance"];
        _assetPairId = [json objectForKey:@"AssetPairId"];
        _issuerId    = [json objectForKey:@"IssuerId"];
        _hideIfZero  = [[json objectForKey:@"HideIfZero"] boolValue];
    }
    return self;
}

@end
