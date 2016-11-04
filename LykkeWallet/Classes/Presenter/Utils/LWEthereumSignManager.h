//
//  LWEthereumSignManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWEthereumSignManager : NSObject

-(id) initWithEthPrivateKey:(NSString *)key;

-(void) signHash:(NSString *) hash withCompletion:(void(^)(NSString *)) completion;
-(void) createAddress;

@end
