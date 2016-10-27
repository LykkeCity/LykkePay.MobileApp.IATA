//
//  LWPrivateWalletsManager.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletsManager.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletModel.h"
#import "LWPrivateKeyManager.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateWalletHistoryCellModel.h"
#import "LWCache.h"
#import "LWPKBackupModel.h"
#import "LWPKTransferModel.h"

@implementation LWPrivateWalletsManager

+ (instancetype)shared
{
    static LWPrivateWalletsManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWPrivateWalletsManager alloc] init];
    });
    return shared;
}

-(void) backupPrivateKeyWithModel:(LWPKBackupModel *) model  withCompletion:(void (^)(BOOL))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWalletBackup" httpMethod:@"POST" getParameters:nil postParameters:@{@"WalletAddress":model.address, @"WalletName":model.walletName, @"SecurityQuestion":model.hint, @"PrivateKeyBackup": model.encodedKey}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
        
    });

}

-(void) loadWalletsWithCompletion:(void (^)(NSArray *))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"GET" getParameters:nil postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion && [dict isKindOfClass:[NSDictionary class]] && dict[@"Wallets"])
        {
            NSMutableArray *array=[[NSMutableArray alloc] init];
            for(NSDictionary *d in dict[@"Wallets"])
            {
                LWPrivateWalletModel *wallet=[[LWPrivateWalletModel alloc] initWithDict:d];
                if(wallet)
                    [array addObject:wallet];
            }
            
            self.wallets=array;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array);
            
            });
        }
    
    });
}



-(void) deleteWallet:(NSString *) address withCompletion:(void (^)(BOOL))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"DELETE" getParameters:@{@"Address":address} postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
            });
        }
        
    });

}


-(void) loadWalletBalances:(NSString *) address withCompletion:(void (^)(NSArray *))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWalletBalance" httpMethod:@"GET" getParameters:@{@"Address":address} postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion && [dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *assets=[[NSMutableArray alloc] init];
            for(NSDictionary *d in dict[@"Balances"])
            {
                LWPrivateWalletAssetModel *model=[[LWPrivateWalletAssetModel alloc] initWithDict:d];
                [assets addObject:model];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
            completion(assets);
            });
        }
        
    });

}


-(void) addNewWallet:(LWPrivateWalletModel *) wallet   withCompletion:(void (^)(BOOL))completion
{
    NSMutableDictionary *params=[@{@"Address":wallet.address, @"Name":wallet.name} mutableCopy];
    if(wallet.encryptedKey)
        params[@"EncodedPrivateKey"]=wallet.encryptedKey;
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
  
            
            dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
            });
        }
        
    });

}

-(void) updateWallet:(LWPrivateWalletModel *) wallet   withCompletion:(void (^)(BOOL))completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWallet" httpMethod:@"PUT" getParameters:nil postParameters:@{@"Address":wallet.address, @"Name":wallet.name}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
        
    });
    
}


-(void) loadHistoryForWallet:(NSString *) address assetId:(NSString *) assetId withCompletion:(void(^)(NSArray *)) completion
{
    NSMutableURLRequest *request=[self createRequestWithAPI:@"PrivateWalletHistory" httpMethod:@"GET" getParameters:@{@"address":address} postParameters:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *result=[self sendRequest:request];
        
        NSLog(@"%@", result);
        if(completion)
        {
            if([result isKindOfClass:[NSArray class]]==NO)
            {
                completion(nil);
                return;
            }
            NSMutableArray *array=[[NSMutableArray alloc] init];
            
            
                for(NSDictionary *d in result)
                {
                    LWPrivateWalletHistoryCellModel *cell=[[LWPrivateWalletHistoryCellModel alloc] initWithDict:d];
                    [array addObject:cell];
                }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array);
            });
        }
        
    });

}

-(void) requestTransferTransaction:(LWPKTransferModel *) transfer withCompletion:(void(^)(NSDictionary *)) completion
{
    NSDictionary *params=@{@"SourceAddress":transfer.sourceWallet.address, @"DestinationAddress":transfer.destinationAddress, @"Amount":transfer.amount, @"AssetId":transfer.asset.assetId};
    NSMutableURLRequest *request=[self createRequestWithAPI:@"GenerateTransferTransaction" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(dict);
            });
        }
        
    });
}

-(void) broadcastTransaction:(NSString *) raw identity:(NSString *) identity withCompletion:(void(^)(BOOL)) completion
{
    NSDictionary *params=@{@"Id":identity, @"Hex":raw};
    NSMutableURLRequest *request=[self createRequestWithAPI:@"BroadcastTransaction" httpMethod:@"POST" getParameters:nil postParameters:params];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict=[self sendRequest:request];
        
        NSLog(@"%@", dict);
        if(completion)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([dict isKindOfClass:[NSError class]])
                    completion(NO);
                else
                    completion(YES);
            });
        }
        
    });
}




#pragma mark HELPERS


-(id) sendRequest:(NSURLRequest *) request
{
    NSURLResponse *responce;
    NSError *error;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
    NSDictionary *result;
    if(data)
    {
        
        result=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if(result && result[@"Result"] && [result[@"Result"] isKindOfClass:[NSNull class]]==NO)
        {
            result=result[@"Result"];
            if([result isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *checkedResult=[result mutableCopy];
                [self checkResult:checkedResult];
                result=checkedResult;
            }
            else if([result isKindOfClass:[NSArray class]])
            {
                result=[self checkArrayResult:result];
            }

            return result;
        }
        if(result[@"Error"] && [[result[@"Error"] class] isSubclassOfClass:[NSNull class]]==NO)
        {
            NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] init];
            if(result[@"Error"][@"Message"])
                userInfo[@"Message"]=result[@"Error"][@"Message"];
            error=[NSError errorWithDomain:[request.URL absoluteString]  code:[result[@"Error"][@"Code"] intValue] userInfo:userInfo];
            
        }
        
    }
    return error;
}


-(NSMutableURLRequest *) createRequestWithAPI:(NSString *) apiMethod httpMethod:(NSString *) httpMethod getParameters:(NSDictionary *) getParams postParameters:(NSDictionary *) postParams
{
    
    NSString *address=[NSString stringWithFormat:@"https://%@/api/%@",[LWKeychainManager instance].address,apiMethod];
    if(getParams)
    {
        NSArray *keys=[getParams allKeys];
        address=[address stringByAppendingString:@"?"];
        for(NSString *key in keys)
            address=[address stringByAppendingFormat:@"&%@=%@",key, getParams[key]];
    }
    
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:httpMethod];
    
    if(postParams)
    {
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postParams options:0 error:nil];
        
        request.HTTPBody = jsonData;
        
//        NSMutableArray *parameterArray = [NSMutableArray array];
//        
//        [postParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
//            NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
//            [parameterArray addObject:param];
//        }];
//        
//        NSString *string = [parameterArray componentsJoinedByString:@"&"];
//        [request setHTTPBody:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *token = [LWKeychainManager instance].token;
    
    
    if (token)
    {
        [request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *device;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        device=@"iPhone";
    else
        device=@"iPad";
    NSString *userAgent=[NSString stringWithFormat:@"DeviceType=%@;AppVersion=%@;ClientFeatures=1", device, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}


-(NSArray *) checkArrayResult:(NSArray *) resArray
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    dict[@"array"]=resArray;
    [self checkResult:dict];
    return dict[@"array"];
}

-(void) checkResult:(NSMutableDictionary *) resultDict
{
    NSArray *keys=[resultDict allKeys];
    for(NSString *k in keys)
    {
        id object=resultDict[k];
        if([object isKindOfClass:[NSNull class]])
        {
            [resultDict removeObjectForKey:k];
        }
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *newDict=[object mutableCopy];
            [self checkResult:newDict];
            resultDict[k]=newDict;
        }
        if([object isKindOfClass:[NSArray class]])
        {
            NSMutableArray *newArr=[object mutableCopy];
            for(int i=0;i<[newArr count];i++)
            {
                id arrElement=newArr[i];
                if([arrElement isKindOfClass:[NSNull class]])
                {
                    [newArr removeObjectAtIndex:i];
                    i--;
                }
                else if([arrElement isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary *newDict=[arrElement mutableCopy];
                    [self checkResult:newDict];
                    [newArr replaceObjectAtIndex:i withObject:newDict];
                    
                }
                
            }
            resultDict[k]=newArr;
        }
    }
}


@end
