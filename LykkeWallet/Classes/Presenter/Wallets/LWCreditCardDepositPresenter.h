//
//  LWCreditCardDepositPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWCreditCardDepositPresenter : LWAuthComplexPresenter


@property (strong, nonatomic) NSString *assetName;
@property (strong, nonatomic) NSString *assetID;
@property (strong, nonatomic) NSString *issuerId;
@end
