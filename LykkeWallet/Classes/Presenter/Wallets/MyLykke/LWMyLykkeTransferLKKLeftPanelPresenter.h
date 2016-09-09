//
//  LWMyLykkeTransferLKKLeftPanelPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWMyLykkeTransferLKKLeftPanelPresenter : LWAuthComplexPresenter

@property id delegate;

@end

@protocol LWMyLykkeTransferLKKLeftPanelPresenterDelegate

-(void) leftPanelPressedBuy:(LWMyLykkeTransferLKKLeftPanelPresenter *) panel;

@end
