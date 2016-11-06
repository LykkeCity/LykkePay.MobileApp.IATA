//
//  LWExchangeDealFormPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 06.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWPacketBuySellAsset.h"


@class LWAssetPairModel;
@class LWAssetPairRateModel;


@interface LWExchangeDealFormPresenter : LWAuthComplexPresenter {
    
}


#pragma mark - Properties

@property (strong, nonatomic) LWAssetPairModel     *assetPair;
@property (strong, nonatomic) LWAssetPairRateModel *assetRate;
@property (assign, nonatomic) LWAssetDealType       assetDealType;

@end
