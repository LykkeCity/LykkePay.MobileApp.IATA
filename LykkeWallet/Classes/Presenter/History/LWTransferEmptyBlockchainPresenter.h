//
//  LWTransferEmptyBlockchainPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 12.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWTransferHistoryItemType;


@interface LWTransferEmptyBlockchainPresenter : LWAuthComplexPresenter {
    
}

@property (strong, nonatomic) LWTransferHistoryItemType *model;

@end
