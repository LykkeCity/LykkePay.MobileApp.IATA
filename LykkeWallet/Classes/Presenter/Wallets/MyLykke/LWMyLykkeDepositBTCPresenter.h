//
//  LWMyLykkeDepositBTCPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWPrivateWalletAssetModel, LWPrivateWalletModel;

@interface LWMyLykkeDepositBTCPresenter : LWAuthComplexPresenter

@property double amount;
@property double lkkAmount;
@property double price;
@property (strong, nonatomic) NSString *assetId;

@end
