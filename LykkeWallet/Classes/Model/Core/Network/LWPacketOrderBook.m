//
//  LWPacketOrderBook.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketOrderBook.h"
#import "LWCache.h"


@implementation LWPacketOrderBook

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    double amount=0;
     for(NSDictionary *ddd in result[@"BuyOrders"]) //Testing
     {
         amount+=[ddd[@"Volume"] doubleValue];
     }
    
    amount=0;
    for(NSDictionary *ddd in result[@"SellOrders"]) //Testing
    {
        amount+=[ddd[@"Volume"] doubleValue];
    }

    
    _sellOrders=[[LWOrderBookElementModel alloc] initWithArray:result[@"BuyOrders"]];  //These orders are from robot. If robot buys then client sells
    _buyOrders=[[LWOrderBookElementModel alloc] initWithArray:result[@"SellOrders"]];
    
    

    [LWCache instance].cachedBuyOrders[_assetPairId]=_buyOrders;
    [LWCache instance].cachedSellOrders[_assetPairId]=_sellOrders;
    
    if([_assetPairId isEqualToString:@"BTCLKK"] || [_assetPairId isEqualToString:@"ETHLKK"])
    {
        LWOrderBookElementModel *m=[_sellOrders copy];
        [m invert];
        [LWCache instance].cachedBuyOrders[_assetPairId]=m;
    }
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

- (NSString *)urlRelative {
    return [NSString stringWithFormat:@"OrderBook/%@", _assetPairId];
}


@end
