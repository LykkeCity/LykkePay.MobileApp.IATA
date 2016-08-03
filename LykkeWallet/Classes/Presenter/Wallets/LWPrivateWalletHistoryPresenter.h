//
//  LWPrivateWalletHistoryPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWAuthComplexPresenter.h"

@class LWPrivateWalletModel;
@class LWPrivateWalletAssetModel;

@interface LWPrivateWalletHistoryPresenter : UIViewController

@property (strong, nonatomic) LWPrivateWalletModel *wallet;
@property (strong, nonatomic) LWPrivateWalletAssetModel *asset;

@end
