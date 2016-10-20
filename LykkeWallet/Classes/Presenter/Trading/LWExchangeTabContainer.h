//
//  LWExchangeTabContainer.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

typedef enum {TAB_ASSET, TAB_GRAPH} TAB_TO_SHOW;

@class LWAssetPairModel;

@interface LWExchangeTabContainer : LWAuthComplexPresenter

@property (strong, nonatomic) LWAssetPairModel *assetPair;
@property TAB_TO_SHOW tabToShow;

@end
