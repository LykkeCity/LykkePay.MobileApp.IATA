//
//  LWPrivateWalletTransferPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
@class LWPrivateWalletModel;
@class LWPKTransferModel;

@interface LWPrivateWalletTransferPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) LWPKTransferModel *transfer;

@end
