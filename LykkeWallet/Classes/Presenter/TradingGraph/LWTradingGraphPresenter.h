//
//  LWTradingGraphPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 18.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWAssetPairModel;


@interface LWTradingGraphPresenter : LWAuthComplexPresenter {
    
}

@property (strong, nonatomic) LWAssetPairModel *assetPair;

@end
