//
//  LWCashEmptyBlockchainPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWCashInOutHistoryItemType;


@interface LWCashEmptyBlockchainPresenter : LWAuthComplexPresenter {
    
}

@property (strong, nonatomic) LWCashInOutHistoryItemType *model;

@end
