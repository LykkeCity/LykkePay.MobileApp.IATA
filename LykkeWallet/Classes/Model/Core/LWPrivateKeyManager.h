//
//  LWPrivateKeyManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//


//words for c1@c1.com: size odor choose rare sweet recipe render hour forget used resource ill

#import <Foundation/Foundation.h>
#import "BTCKey.h"

@interface LWPrivateKeyManager : NSObject


@property (strong, readonly) BTCKey *privateKeyLykke;
@property (strong, readonly) NSString *encryptedKeyLykke;
@property (strong, readonly) NSString *publicKeyLykke;
@property (strong, readonly) NSString *wifPrivateKeyLykke;


+ (instancetype)shared;

-(BOOL) isDevServer;

//-(void) generatePrivateKey;
-(void) decryptLykkePrivateKeyAndSave:(NSString *) encodedPrivateKey;

-(NSString *) decryptPrivateKey:(NSString *)encryptedPrivateKeyData withPassword:(NSString *) password;

-(NSString *) encryptKey:(NSString *) privateKey password:(NSString *) password;

+(NSString *) addressFromPrivateKeyWIF:(NSString *) wif;

+(NSString *) encodedPrivateKeyWif:(NSString *) key withPassPhrase:(NSString *) passPhrase;
+(NSString *) decodedPrivateKeyWif:(NSString *) encodedKey withPassPhrase:(NSString *) passPhrase;

+(NSArray *) generateSeedWords;


-(BOOL) savePrivateKeyLykkeFromSeedWords:(NSArray *) words;

-(NSString *) availableSecondaryPrivateKey;

-(NSString *) signatureForMessageWithLykkeKey:(NSString *) message;

-(void) logoutUser;


@end
