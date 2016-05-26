//
//  LWAuthPINEnterPresenter.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 17.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthStepPresenter.h"

@interface LWAuthPINEnterPresenter : LWAuthStepPresenter

@property (strong, nonatomic) void (^isSuccess) (BOOL success);


@end
