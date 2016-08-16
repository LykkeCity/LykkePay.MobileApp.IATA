//
//  LWCreateEditPrivateWalletPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@class LWPrivateWalletModel;

@interface LWCreateEditPrivateWalletPresenter : LWAuthComplexPresenter


@property BOOL editMode;

@property (strong, nonatomic) LWPrivateWalletModel *wallet;

@end
