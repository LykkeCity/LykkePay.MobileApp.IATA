//
//  LWWithdrawFundsPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 30.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@interface LWWithdrawFundsPresenter : LWAuthComplexPresenter {
    
}

@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSString *assetSymbol;

@end
