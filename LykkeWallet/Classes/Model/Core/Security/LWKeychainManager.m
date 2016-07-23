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
#import "LWPrivateKeyManager.h"
#import <Valet/Valet.h>

static NSString *const kKeychainManagerAppId    = @"LykkeWallet";
static NSString *const kKeychainManagerToken    = @"Token";
static NSString *const kKeychainManagerLogin    = @"Login";
static NSString *const kKeychainManagerPhone    = @"Phone";
static NSString *const kKeychainManagerFullName = @"FullName";
static NSString *const kKeychainManagerAddress  = @"Address";
static NSString *const kKeychainManagerPassword  = @"Password";
static NSString *const kKeychainManagerPIN  = @"Pin";
static NSString *const kKeychainManagerEncodedPrivateKey  = @"EncodedPrivateKey";

static NSString *const kKeychainManagerNotificationsTag  = @"NotificationsTag";

static NSString *const kKeychainManagerLykkePrivateKey =@"LykkePrivateKey";
static NSString *const kKeychainManagerUserPrivateWalletsAddresses=@"UserWalletsAddresses";




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


- (void)saveLogin:(NSString *)login password:(NSString *)password token:(NSString *)token
{
    [valet setString:token forKey:kKeychainManagerToken];
    [valet setString:login forKey:kKeychainManagerLogin];
    [valet setString:password forKey:kKeychainManagerPassword];
    
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


-(void) saveEncodedPrivateKey:(NSString *)key
{
    [valet setString:key forKey:kKeychainManagerEncodedPrivateKey];
}

-(void) saveNotificationsTag:(NSString *)tag
{
    [valet setString:tag forKey:kKeychainManagerNotificationsTag];
}

-(void) clearLykkePrivateKey //Testing
{
    [valet removeObjectForKey:kKeychainManagerLykkePrivateKey];

}

- (void)clear {
    [valet removeObjectForKey:kKeychainManagerToken];
    [valet removeObjectForKey:kKeychainManagerLogin];
    [valet removeObjectForKey:kKeychainManagerPhone];
    [valet removeObjectForKey:kKeychainManagerFullName];
    [valet removeObjectForKey:kKeychainManagerPassword];
    [valet removeObjectForKey:kKeychainManagerNotificationsTag];
    
//    NSData *data=[valet objectForKey:kKeychainManagerUserPrivateWalletsAddresses];
//    NSArray *wallets = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    for(NSString *w in wallets)
//    {
//        [valet removeObjectForKey:w];
//    }
    [valet removeObjectForKey:kKeychainManagerLykkePrivateKey];
    
}

-(void) saveLykkePrivateKey:(NSString *)privateKey
{
    [valet setString:privateKey forKey:kKeychainManagerLykkePrivateKey];
}

-(void) savePrivateKey:(NSString *)privateKey forWalletAddress:(NSString *)address
{
    NSData *data=[valet objectForKey:kKeychainManagerUserPrivateWalletsAddresses];
    NSMutableArray *wallets;// = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    if(data)
        wallets=[[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    else
        wallets=[[NSMutableArray alloc] init];
    if([wallets containsObject:address]==NO)
    {
        [wallets addObject:address];
        data = [NSKeyedArchiver archivedDataWithRootObject:wallets];
        [valet setObject:data forKey:kKeychainManagerUserPrivateWalletsAddresses];
    }
    [valet setString:privateKey forKey:address];
}



#pragma mark - Properties

- (NSString *)login {
    return [valet stringForKey:kKeychainManagerLogin];
}

- (NSString *)token {
    return [valet stringForKey:kKeychainManagerToken];
}

-(NSString *) password
{
    return [valet stringForKey:kKeychainManagerPassword];
}

-(NSString *) notificationsTag
{
    return [valet stringForKey:kKeychainManagerNotificationsTag];
}

-(NSString *) privateKeyLykke
{
    return [valet stringForKey:kKeychainManagerLykkePrivateKey];
}

-(NSString *) privateKeyForWalletAddress:(NSString *) address
{
    return [valet stringForKey:address];
}




- (NSString *)address {
    
//    return kProductionServer;//Testing
    
//    return @"http://testtestest.me";//Andrey
    
//    return kStagingTestServer;

#ifdef PROJECT_IATA
    return kDevelopTestServer;
#else
    
#ifdef TEST
    NSString *result = [valet stringForKey:kKeychainManagerAddress];
    // validate for nil, empty or non-existing addresses
    if (!result || [result isEqualToString:@""]) {
        [self saveAddress:kDevelopTestServer];
        return kDevelopTestServer;
    }
    else if (![result isEqualToString:kTestingTestServer] &&
             ![result isEqualToString:kDevelopTestServer] &&
             ![result isEqualToString:kStagingTestServer]) {
        [self saveAddress:kDevelopTestServer];
        return kDevelopTestServer;
    }
    return result;
#else
    return kProductionServer;
#endif
    
#endif
}

- (BOOL)isAuthenticated {
    return (self.token && ![self.token isEqualToString:@""] && [LWPrivateKeyManager shared].privateKeyLykke);
}

- (NSString *)fullName {
    return [valet stringForKey:kKeychainManagerFullName];
}

@end
