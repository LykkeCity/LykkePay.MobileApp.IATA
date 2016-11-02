//
//  LWPrivateWalletAddressPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWPrivateWalletModel;

@interface LWPrivateWalletAddressPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) LWPrivateWalletModel *wallet;

@end
