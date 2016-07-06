//
//  LWAssetPairModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetPairModel.h"
#import "LWUtils.h"

@interface LWAssetPairModel()
{
    BOOL isInverted;
}

@end


@implementation LWAssetPairModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        isInverted=NO;
        
        _identity = [json objectForKey:@"Id"];
        _group    = [json objectForKey:@"Group"];
//        _name     = [json objectForKey:@"Name"];
        _accuracy = [json objectForKey:@"Accuracy"];
        _baseAssetId    = [json objectForKey:@"BaseAssetId"];
        _quotingAssetId = [json objectForKey:@"QuotingAssetId"];
        
        _normalAccuracy=_accuracy;
        _invertedAccuracy = [json objectForKey:@"InvertedAccuracy"];

        _name=[NSString stringWithFormat:@"%@/%@", [LWUtils baseAssetTitle:self], [LWUtils quotedAssetTitle:self]];
        
        self.inverted=[[json objectForKey:@"Inverted"] boolValue];

        
    }
    return self;
}

-(void) setInverted:(BOOL)inverted
{
    if(isInverted!=inverted)
    {
        isInverted=inverted;
        id tmpID=_baseAssetId;
        _baseAssetId=_quotingAssetId;
        _quotingAssetId=tmpID;
        if(isInverted)
            _accuracy=_invertedAccuracy;
        else
            _accuracy=_normalAccuracy;
    }
}

-(BOOL) inverted
{
    return isInverted;
}

@end
