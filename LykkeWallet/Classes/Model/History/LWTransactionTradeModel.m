//
//  LWTransactionTradeModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionTradeModel.h"
#import "NSString+Date.h"


@implementation LWTransactionTradeModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        NSString *date = [json objectForKey:@"DateTime"];

        _identity = [json objectForKey:@"Id"];
        _dateTime = [date toDate];
        _volume   = [json objectForKey:@"Volume"];
        _asset    = [json objectForKey:@"Asset"];
        _iconId   = [json objectForKey:@"IconId"];
    }
    return self;
}

@end
