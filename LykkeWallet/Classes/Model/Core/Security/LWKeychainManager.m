//
//  LWKeychainManager.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKeychainManager.h"
#import "LWPersonalData.h"
#import "LWConstants.h"
#import <Valet/Valet.h>

static NSString *const kKeychainManagerAppId    = @"LykkeWallet";
static NSString *const kKeychainManagerToken    = @"Token";
static NSString *const kKeychainManagerLogin    = @"Login";
static NSString *const kKeychainManagerPhone    = @"Phone";
static NSString *const kKeychainManagerFullName = @"FullName";
static NSString *const kKeychainManagerAddress  = @"Address";


@interface LWKeychainManager () {
    VALValet *valet;
}

@end


@implementation LWKeychainManager


#pragma mark - Root

SINGLETON_INIT {
    self = [super init];
    if (self) {
        valet = [[VALValet alloc] initWithIdentifier:kKeychainManagerAppId
                                       accessibility:VALAccessibilityWhenUnlocked];
//        [self clear]; //Andrey
    }
    return self;
}


#pragma mark - Common

- (void)saveLogin:(NSString *)login token:(NSString *)token {
    [valet setString:token forKey:kKeychainManagerToken];
    [valet setString:login forKey:kKeychainManagerLogin];
}

- (void)savePersonalData:(LWPersonalData *)personalData {
    if (personalData) {
        if (personalData.phone
            && ![personalData.phone isKindOfClass:[NSNull class]]) {
            [valet setString:personalData.phone    forKey:kKeychainManagerPhone];
        }
        if (personalData.fullName
            && ![personalData.fullName isKindOfClass:[NSNull class]]) {
            [valet setString:personalData.fullName forKey:kKeychainManagerFullName];
        }
    }
}

- (void)saveAddress:(NSString *)address {
    [valet setString:address forKey:kKeychainManagerAddress];
}

- (void)clear {
    [valet removeObjectForKey:kKeychainManagerToken];
    [valet removeObjectForKey:kKeychainManagerLogin];
    [valet removeObjectForKey:kKeychainManagerPhone];
    [valet removeObjectForKey:kKeychainManagerFullName];
}


#pragma mark - Properties

- (NSString *)login {
    return [valet stringForKey:kKeychainManagerLogin];
}

- (NSString *)token {
    return [valet stringForKey:kKeychainManagerToken];
}

- (NSString *)address {
    
//    return @"http://testtestest.me";//Andrey
    
//    return kProductionServer;

#ifdef PROJECT_IATA
    return kDevelopTestServer;
#else
    
#ifdef TEST
    NSString *result = [valet stringForKey:kKeychainManagerAddress];
    // validate for nil, empty or non-existing addresses
    if (!result || [result isEqualToString:@""]) {
        [self saveAddress:kDemoTestServer];
        return kDemoTestServer;
    }
    else if (![result isEqualToString:kDemoTestServer] &&
             ![result isEqualToString:kDevelopTestServer] &&
             ![result isEqualToString:kStagingTestServer]) {
        [self saveAddress:kDemoTestServer];
        return kDemoTestServer;
    }
    return result;
#else
    return kProductionServer;
#endif
    
#endif
}

- (BOOL)isAuthenticated {
    return (self.token && ![self.token isEqualToString:@""]);
}

- (NSString *)fullName {
    return [valet stringForKey:kKeychainManagerFullName];
}

@end
