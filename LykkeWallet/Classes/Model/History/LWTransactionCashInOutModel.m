//
//  LWTransactionCashInOutModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionCashInOutModel.h"
#import "NSString+Date.h"


@implementation LWTransactionCashInOutModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _identity = [json objectForKey:@"Id"];
        _amount   = [json objectForKey:@"Amount"];
        NSString *date = [json objectForKey:@"DateTime"];
        _dateTime = [date toDate];
        _asset    = [json objectForKey:@"Asset"];
        _iconId   = [json objectForKey:@"IconId"];
    }
    return self;
}

@end
