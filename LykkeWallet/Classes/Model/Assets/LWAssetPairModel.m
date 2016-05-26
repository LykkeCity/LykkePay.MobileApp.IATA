//
//  LWAssetPairModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetPairModel.h"


@implementation LWAssetPairModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _group    = [json objectForKey:@"Group"];
        _name     = [json objectForKey:@"Name"];
        _accuracy = [json objectForKey:@"Accuracy"];
        _baseAssetId    = [json objectForKey:@"BaseAssetId"];
        _quotingAssetId = [json objectForKey:@"QuotingAssetId"];
    }
    return self;
}

@end
