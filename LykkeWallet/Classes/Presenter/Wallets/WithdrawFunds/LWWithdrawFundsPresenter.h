//
//  LWWithdrawFundsPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 30.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"


@interface LWWithdrawFundsPresenter : LWAuthPresenter {
    
}

@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSString *assetPairId;

@end
