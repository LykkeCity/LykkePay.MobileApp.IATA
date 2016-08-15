//
//  LWTransactionManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWPKTransferModel;
@class BTCTransaction;

@interface LWTransactionManager : NSObject

+(BTCTransaction *) signMultiSigTransaction:(NSString *) transaction withKey:(NSString *) key;
+(NSString *) signTransactionRaw:(NSString *) rawString forModel:(LWPKTransferModel *) model;

@end
