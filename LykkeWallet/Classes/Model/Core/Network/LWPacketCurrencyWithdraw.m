//
//  LWPacketCurrencyWithdraw.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketCurrencyWithdraw.h"
#import "LWPrivateKeyManager.h"

@implementation LWPacketCurrencyWithdraw
#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    
}


- (NSString *)urlRelative {
    return @"CashOutSwiftRequest";
}

-(NSDictionary *) params
{
    
    NSDictionary *params=@{@"AssetId":self.assetId, @"Bic":self.bic, @"AccNumber":self.accountNumber, @"AccName":self.accountName, @"Postcheck":self.postCheck, @"Amount":self.amount, @"PrivateKey":[LWPrivateKeyManager shared].wifPrivateKeyLykke};
    NSLog(@"%@", params);
    return params;
}
@end
