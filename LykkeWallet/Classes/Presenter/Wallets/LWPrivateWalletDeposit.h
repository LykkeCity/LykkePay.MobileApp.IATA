//
//  LWPrivateWalletDeposit.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWPrivateWalletAssetModel, LWPrivateWalletModel;

@interface LWPrivateWalletDeposit : LWAuthComplexPresenter

@property (strong, nonatomic) LWPrivateWalletAssetModel *asset;
@property (strong, nonatomic) LWPrivateWalletModel *wallet;

@end
