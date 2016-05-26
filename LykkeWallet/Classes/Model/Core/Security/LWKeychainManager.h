//
//  LWKeychainManager.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

@class LWPersonalData;

@interface LWKeychainManager : NSObject {
    
}

SINGLETON_DECLARE

@property (readonly, nonatomic) NSString *login;
@property (readonly, nonatomic) NSString *token;
@property (readonly, nonatomic) NSString *address;
@property (readonly, nonatomic) BOOL     isAuthenticated;


#pragma mark - Common

- (void)saveLogin:(NSString *)login token:(NSString *)token;
- (void)savePersonalData:(LWPersonalData *)personalData;
- (void)saveAddress:(NSString *)address;
- (void)clear;


#pragma mark - Properties

- (NSString *)fullName;

@end
