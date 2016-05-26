//
//  LWTradingLinearGraphPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWAssetPairModel;

@interface LWTradingLinearGraphPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) LWAssetPairModel *assetPair;

@end
