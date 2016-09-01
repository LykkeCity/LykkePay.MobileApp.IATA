//
//  LWPrivateWalletEmptyHistoryPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWRefreshControlView;

@interface LWPrivateWalletEmptyHistoryPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) LWRefreshControlView *refreshControl;
@property id delegate;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end


@protocol LWPrivateWalletEmptyHistoryPresenterDelegate

-(void) reloadHistory;
-(void) depositPressed;

@end