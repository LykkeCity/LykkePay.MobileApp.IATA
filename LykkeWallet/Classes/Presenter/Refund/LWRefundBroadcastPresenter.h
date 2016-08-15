//
//  LWRefundBroadcastPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 03/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import <UIKit/UIKit.h>

@interface LWRefundBroadcastPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) NSString *transactionText;
@property NSTimeInterval lockTime;

@end
