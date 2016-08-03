//
//  LWPrivateWalletHistoryCellModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletHistoryCellModel.h"

@implementation LWPrivateWalletHistoryCellModel

-(id) initWithDict:(NSDictionary *) d
{
    self=[super init];
    
    self.amount=@(20);
    self.assetId=@"BTC";
    self.baseAssetAmount=@(1000);
    self.type=LWPrivateWalletTransferTypeSend;
    
    self.date=[NSDate date];
    
    return self;
}

@end
