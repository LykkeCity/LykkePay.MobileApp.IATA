//
//  LWPacketCountryCodes.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCountryCodes.h"
#import "LWCountryModel.h"


@implementation LWPacketCountryCodes


#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    // read assets
    NSMutableArray *countries = [NSMutableArray new];
    for (NSDictionary *item in result[@"CountriesList"]) {
        [countries addObject:[[LWCountryModel alloc] initWithJSON:item]];
    }
    _countries = countries;
}

- (NSString *)urlRelative {
    return @"GetCountryPhoneCodes";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

@end
