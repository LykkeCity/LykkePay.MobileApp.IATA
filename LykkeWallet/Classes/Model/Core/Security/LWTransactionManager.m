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
#import "BTCTransactionOutput.h"
#import "LWPKTransferModel.h"
#import "LWUtils.h"
#import "BTCScript.h"
#import "BTCAddress.h"
#import "BTCData.h"


@implementation LWTransactionManager

+(BTCTransaction *) signMultiSigTransaction:(NSString *)_transaction withKey:(NSString *)privateKey
{
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:_transaction];
    
    if(!transaction)
        return nil;
    //    BTCKey *key=[[BTCKey alloc] initWithWIF:@"cNTXye9kVVnKegjkngGm6DPauM7NACNJd3K93SgeucMCemuRANux"];//cNj3wXLNcr5fMtWcqaFgLGBBi9qiEGKYrwr2dcP2QnNSrugxiJEL
    BTCKey *key=[[BTCKey alloc] initWithWIF:privateKey];
    if(!key)
        return nil;
    if(transaction.inputs.count==0)
        return nil;
    
    for(BTCTransactionInput *input in transaction.inputs)
    {
            BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
            
            NSArray *chunks=input.signatureScript.scriptChunks;
            if(!chunks || chunks.count!=4)
                return nil;
            
            BTCScript *tempSigScript=[[BTCScript alloc] initWithData:[chunks[3] pushdata]];
            
            NSData* hash = [transaction signatureHashForScript:tempSigScript inputIndex:(uint32_t)[transaction.inputs indexOfObject:input] hashType:hashtype error:NULL];
            
            if(!hash)
                return nil;

            
            NSData *signature=[key signatureForHash:hash hashType:SIGHASH_ALL];
        if(!signature)
            return nil;
            
            
            BTCScript *newScript=[[BTCScript alloc] init];
            [newScript appendOpcode:OP_0];
            [newScript appendData:signature];
            [newScript appendData:[chunks[2] pushdata]];
            [newScript appendData:[chunks[3] pushdata]];
            
            input.signatureScript=newScript;
        
    }
    
    
    
    NSString *transactiondata=[LWUtils hexStringFromData:transaction.data];
    NSLog(@"%@", transactiondata);
    
    
    
    return transaction;
    
}

+(NSString *) signTransactionRaw:(NSString *) rawString forModel:(LWPKTransferModel *) model
{
    
    BTCTransaction *transaction=[[BTCTransaction alloc] initWithHex:rawString];
     BTCKey *key=[[BTCKey alloc] initWithWIF:model.sourceWallet.privateKey];
//    key=[[BTCKey alloc] initWithWIF:@"cPTyHRvgMLwgiPZqrZidF5G4u5wuNREw6t3yNdQFtByPQ3b5R5hm"];//cNj3wXLNcr5fMtWcqaFgLGBBi9qiEGKYrwr2dcP2QnNSrugxiJEL
    NSMutableArray *newInputs=[[NSMutableArray alloc] init];
    for(BTCTransactionInput *input in transaction.inputs)
    {
        BTCScript *signature=input.signatureScript;
        if(signature.hex.length==0) //Need to sign
        {
            
            
            BTCScript* p2cpkhScript = [[BTCScript alloc] initWithAddress:[BTCPublicKeyAddress addressWithData:BTCHash160(key.compressedPublicKey)]];

            
            NSData *hash=[transaction signatureHashForScript:[p2cpkhScript copy] inputIndex:(uint32_t)[transaction.inputs indexOfObject:input] hashType:SIGHASH_ALL error:nil];


            NSData *signature=[key signatureForHash:hash hashType:SIGHASH_ALL];
            
            BTCScript *newScript=[[BTCScript alloc] init];
            
            NSData *pubKey=key.publicKey;
            [newScript appendData:signature];
            [newScript appendData:pubKey];
            input.signatureScript=newScript;
            [newInputs addObject:input];
            
            
        }
    }
    

    
    NSString *transactiondata=[LWUtils hexStringFromData:transaction.data];
    NSLog(@"%@", transactiondata);
    
    
    
    return transactiondata;
}


//+(void) testCreateTransaction
//{
//    BTCTransaction *transaction=[[BTCTransaction alloc] init];
//    BTCTransactionInput *input=[[BTCTransactionInput alloc] init];
//    input.previousHash=[LWUtils dataFromHexString:@"d784ed921e6ff90bdac322319881808590eafc5a672519a9d43e2b643372cb9b"];
//    input.previousIndex=0;
//    BTCKey *key=[[BTCKey alloc] initWithWIF:@"cNTXye9kVVnKegjkngGm6DPauM7NACNJd3K93SgeucMCemuRANux"];
//    
//    
//    BTCScript* p2cpkhScript = [[BTCScript alloc] initWithAddress:[BTCPublicKeyAddress addressWithData:BTCHash160(key.compressedPublicKey)]];
//    
//    
//    NSData *hash=input.previousHash;
//    
//    
//
//    
//    BTCTransactionOutput *output1=[[BTCTransactionOutput alloc] initWithValue:200000000 address:[BTCAddress addressWithString:@"mwkgBib9yKUGaTEPHi65ZNuhspFNZFGwAG"]];
//    BTCTransactionOutput *output2=[[BTCTransactionOutput alloc] initWithValue:1424990000 address:[BTCAddress addressWithString:@"mhtvsY1QTqFZNkbCn1qHHzqWQEjDpUFXHL"]];
//    
//    transaction.outputs=@[output1, output2];
//    transaction.inputs=@[input];
//
//    
//    NSData* sighash = [transaction signatureHashForScript:[p2cpkhScript copy] inputIndex:0 hashType:SIGHASH_ALL error:nil];
//    
//    NSData *signature=[key signatureForHash:sighash hashType:SIGHASH_ALL];
//    
//    //
//    
//    //            NSData *signature=[key signatureForHash:hash hashType:BTCSignatureHashTypeAll];
//    
//    BTCScript *newScript=[[BTCScript alloc] init];
//    
//    NSData *pubKey=key.publicKey;
//    [newScript appendData:signature];
//    [newScript appendData:pubKey];
//    input.signatureScript=newScript;
//    
//    NSString *transactiondata=[LWUtils hexStringFromData:transaction.data];
//    NSLog(@"%@", transactiondata);
//
//}
//
//
//+(void) testCreateTransaction2
//{
//
//
//}

@end
