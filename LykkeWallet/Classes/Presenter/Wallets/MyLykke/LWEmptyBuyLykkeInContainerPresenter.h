//
//  LWEmptyBuyLykkeInContainerPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 04/11/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWEmptyBuyLykkeInContainerPresenter : LWAuthComplexPresenter

@property id delegate;

@end


@protocol  LWEmptyBuyLykkeInContainerPresenterDelegate

-(void) emptyPresenterPressedDeposit;

@end
