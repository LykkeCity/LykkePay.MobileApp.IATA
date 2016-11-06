//
//  LWTradingWalletPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBaseHistoryPresenter.h"


@interface LWTradingWalletPresenter : LWBaseHistoryPresenter {
    
}


#pragma mark - Properties

@property (copy,   nonatomic) NSString *assetName;
@property (copy,   nonatomic) NSString *issuerId;

@end
