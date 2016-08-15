//
//  LWExchangeEmptyBlockchainPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWExchangeInfoModel;
@class  LWBaseHistoryItemType;


@interface LWExchangeEmptyBlockchainPresenter : LWAuthComplexPresenter {
    
}

@property (nonatomic, strong) NSString            *asset;
@property (nonatomic, strong) LWExchangeInfoModel *model;
@property (nonatomic, strong) LWBaseHistoryItemType *historyItem;

@end
