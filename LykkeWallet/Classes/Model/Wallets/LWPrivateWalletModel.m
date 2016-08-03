//
//  LWPrivateWalletModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletModel.h"
#import "LWKeychainManager.h"
#import "LWPrivateWalletAssetModel.h"
#import "LWPrivateKeyManager.h"

@implementation LWPrivateWalletModel

-(id) initWithDict:(NSDictionary *) d
{
    self=[super init];
    
    self.address=d[@"Address"];
    self.name=d[@"Name"];
    self.privateKey=[[LWKeychainManager instance] privateKeyForWalletAddress:self.address];
    if(self.privateKey==nil && [self.address isEqualToString:[LWPrivateKeyManager addressFromPrivateKeyWIF:[LWPrivateKeyManager shared].wifPrivateKeyLykke]])
    {
        self.privateKey=[LWPrivateKeyManager shared].wifPrivateKeyLykke;
    }
    self.iconURL=d[@"MediumIconUrl"];
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for(NSDictionary *b in d[@"Balances"])
    {
        LWPrivateWalletAssetModel *asset=[[LWPrivateWalletAssetModel alloc] initWithDict:b];
        [arr addObject:asset];
    }
    self.assets=arr;
    
    return self;
}


@end
