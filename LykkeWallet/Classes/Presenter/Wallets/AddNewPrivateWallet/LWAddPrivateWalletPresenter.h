//
//  LWAddPrivateWalletPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWPrivateWalletModel;

@interface LWAddPrivateWalletPresenter : LWAuthComplexPresenter

@property BOOL editMode;

@property (strong, nonatomic) LWPrivateWalletModel *wallet;

@end
