//
//  LWChoosePrivateWalletView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWPrivateWalletModel;

@interface LWChoosePrivateWalletView : UIView

+(void) showWithCurrentWallet:(LWPrivateWalletModel *)current completion:(void(^)(LWPrivateWalletModel *)) completion;

@end
