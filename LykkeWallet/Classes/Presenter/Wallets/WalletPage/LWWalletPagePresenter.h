//
//  LWWalletPagePresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKPresenter.h"


@class LWBankCardsData;


@interface LWWalletPagePresenter : TKPresenter {
    
}

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) LWBankCardsData *cardData;

@end
