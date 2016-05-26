//
//  LWExchangeResultPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWAssetPairModel;
@class LWAssetDealModel;


@interface LWExchangeResultPresenter : LWAuthComplexPresenter {
    
}


#pragma mark - Properties

@property (strong, nonatomic) LWAssetDealModel *purchase;

@end
