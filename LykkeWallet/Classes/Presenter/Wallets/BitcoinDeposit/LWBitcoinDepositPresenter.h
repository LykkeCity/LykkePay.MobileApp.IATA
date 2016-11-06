//
//  LWBitcoinDepositPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"


@interface LWBitcoinDepositPresenter : LWAuthPresenter {
    
}

@property (strong, nonatomic) NSString *assetName;
@property (strong, nonatomic) NSString *issuerId;

@end
