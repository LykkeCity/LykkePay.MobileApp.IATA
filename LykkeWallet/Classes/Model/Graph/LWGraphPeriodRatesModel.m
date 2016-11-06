//
//  LWGraphPeriodRatesModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWGraphPeriodRatesModel.h"
#import "NSString+Date.h"


@implementation LWGraphPeriodRatesModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        NSString *fixingTimeString = [json objectForKey:@"FixingTime"];
        NSString *startTimeString  = [json objectForKey:@"StartTime"];
        NSString *endTimeString    = [json objectForKey:@"EndTime"];
        
        _fixingTime = [fixingTimeString toDate];
        _startTime  = [startTimeString toDate];
        _endTime    = [endTimeString toDate];
        
        id rateObject = [json objectForKey:@"Rate"];
        if (rateObject) {
            _percantageChange = [rateObject objectForKey:@"PChange"];
            _rates            = [rateObject objectForKey:@"ChngGrph"];
        }
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWGraphPeriodRatesModel* data = [[[self class] allocWithZone:zone] init];
    data.fixingTime       = [self.fixingTime copy];
    data.startTime        = [self.startTime copy];
    data.endTime          = [self.endTime copy];
    data.percantageChange = [self.percantageChange copy];
    data.rates            = [self.rates copy];
    
    return data;
}

@end
