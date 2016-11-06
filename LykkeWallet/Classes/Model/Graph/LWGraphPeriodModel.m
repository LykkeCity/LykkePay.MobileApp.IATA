//
//  LWGraphPeriodModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWGraphPeriodModel.h"


@implementation LWGraphPeriodModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _name  = [json objectForKey:@"Name"];
        _value = [json objectForKey:@"Value"];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    LWGraphPeriodModel* data = [[[self class] allocWithZone:zone] init];
    data.name  = [self.name copy];
    data.value = [self.value copy];
    
    return data;
}

@end
