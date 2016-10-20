//
//  LWExchangeOrderPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWOrderBookElementModel.h"


@interface LWExchangeOrderPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) LWOrderBookElementModel *orderBookBuy;
@property (strong, nonatomic) LWOrderBookElementModel *orderBookSell;

@property (strong, nonatomic) LWAssetPairModel *assetPair;


@end
