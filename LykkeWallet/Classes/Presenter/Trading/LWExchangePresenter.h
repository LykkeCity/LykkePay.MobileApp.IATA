//
//  LWExchangePresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 05.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWAssetPairModel.h"
#import "LWExchangeTabContainer.h"

@interface LWExchangePresenter : LWAuthComplexPresenter {
    
}

@property id delegate;
@end


@protocol LWExchangePresenterDelegate

-(void) exchangePresenterChosenPair:(LWAssetPairModel *) pair tabToShow:(TAB_TO_SHOW) tabToShow;

@end
