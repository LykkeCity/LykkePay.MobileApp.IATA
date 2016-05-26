//
//  LWPersonalData.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 26.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWPersonalData.h"


@implementation LWPersonalData {
    
}

- (instancetype)initWithJSON:(id)json {
    if (json && ![json isKindOfClass:[NSNull class]]) {
        self = [super initWithJSON:json];
        if (self) {
            _phone    = [json objectForKey:@"Phone"];
            _email    = [json objectForKey:@"Email"];
            _fullName = [json objectForKey:@"FullName"];
        }
        return self;
    }
    return nil;
}

@end
