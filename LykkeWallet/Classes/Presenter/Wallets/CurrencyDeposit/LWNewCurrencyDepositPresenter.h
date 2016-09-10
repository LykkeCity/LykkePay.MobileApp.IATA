//
//  LWNewCurrencyDepositPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWNewCurrencyDepositPresenter : LWAuthComplexPresenter

@property double amount;

@property (strong, nonatomic) NSString *assetName;
@property (strong, nonatomic) NSString *assetID;
@property (strong, nonatomic) NSString *issuerId;

@end
