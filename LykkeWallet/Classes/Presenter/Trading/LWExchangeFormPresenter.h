//
//  LWExchangeFormPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWAssetPairModel;
@class LWAssetPairRateModel;


@interface LWExchangeFormPresenter : LWAuthComplexPresenter {
    
}


#pragma mark - Properties

@property (strong, nonatomic) LWAssetPairModel *assetPair;
@property (strong, nonatomic) LWAssetPairRateModel *assetRate;

@end
