//
//  LWWithdrawCurrencyPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthPresenter.h"

@interface LWWithdrawCurrencyPresenter : LWAuthPresenter


@property (strong, nonatomic) NSString *assetName;
@property (strong, nonatomic) NSString *assetID;
@property (strong, nonatomic) NSString *issuerId;

@property (strong, nonatomic) NSNumber *amount;

@end
