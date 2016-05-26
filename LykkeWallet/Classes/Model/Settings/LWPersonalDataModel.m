//
//  LWPersonalDataModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPersonalDataModel.h"


@implementation LWPersonalDataModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self) {
        _fullName = json[@"FullName"];
        _email    = json[@"Email"];
        _phone    = json[@"Phone"];
        _country  = json[@"Country"];
        _address  = json[@"Address"];
        _city     = json[@"City"];
        _zip      = json[@"Zip"];
    }
    return self;
}


#pragma mark - Utils

- (BOOL)isFullNameEmpty {
    BOOL const isFullNameEmpty = self.fullName == nil ||
                            [self.fullName isKindOfClass:[NSNull class]] ||
                            [self.fullName isEqualToString:@""];
    return isFullNameEmpty;
}

- (BOOL)isPhoneEmpty {
    BOOL const isPhoneEmpty = self.phone == nil ||
                            [self.phone isKindOfClass:[NSNull class]] ||
                            [self.phone isEqualToString:@""];
    return isPhoneEmpty;
}

@end
