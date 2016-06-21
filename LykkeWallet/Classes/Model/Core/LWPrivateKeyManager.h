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

+ (instancetype)shared;

-(void) generatePrivateKey;

@end
