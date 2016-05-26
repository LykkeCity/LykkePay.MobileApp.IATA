//
//  LWWithdrawInputPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@interface LWWithdrawInputPresenter : LWAuthComplexPresenter {
    
}


#pragma mark - Properties

@property (copy, nonatomic) NSString *assetId;
@property (copy, nonatomic) NSString *bitcoinString;
@property (copy, nonatomic) NSString *assetSymbol;


@end
