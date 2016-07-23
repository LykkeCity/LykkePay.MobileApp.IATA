//
//  LWPrivateKeyManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCKey.h"

@interface LWPrivateKeyManager : NSObject


@property (strong, readonly) BTCKey *privateKeyLykke;
@property (strong, readonly) NSString *encryptedKeyLykke;
@property (strong, readonly) NSString *publicKeyLykke;
@property (strong, readonly) NSString *wifPrivateKeyLykke;


+ (instancetype)shared;

-(void) generatePrivateKey;
-(void) decryptLykkePrivateKeyAndSave:(NSString *) encodedPrivateKey;

+(NSString *) addressFromPrivateKeyWIF:(NSString *) wif;


@end
