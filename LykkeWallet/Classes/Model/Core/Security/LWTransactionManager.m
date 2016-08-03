//
//  LWTransactionManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTransactionManager.h"
#import "BTCKey.h"
#import "BTCTransaction.h"
#import "BTCTransactionInput.h"

@implementation LWTransactionManager

+(NSString *) signMultiSigTransaction:(NSString *)_transaction withKey:(NSString *)key
{
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:_transaction];
    NSArray *inputs=transaction.inputs;
    
    
    
    
    
    
    return nil;
}

@end
