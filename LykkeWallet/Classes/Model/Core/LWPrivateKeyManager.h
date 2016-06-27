//
//  LWPrivateKeyManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPrivateKeyManager : NSObject


@property (strong, readonly) NSString *privateKey;
@property (strong, readonly) NSString *encryptedKey;
@property (strong, readonly) NSString *publicKey;
@property (strong, readonly) NSString *privateKeyWif;
@property (strong, readonly) NSString *bitcoinAddress;


+ (instancetype)shared;

-(void) generatePrivateKey;
-(void) decryptKeyIfPossible;


@end
