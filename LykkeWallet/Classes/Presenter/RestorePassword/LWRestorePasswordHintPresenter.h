//
//  LWRestorePasswordHintPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWRecoveryPasswordModel;

@interface LWRestorePasswordHintPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) LWRecoveryPasswordModel *recModel;

@end
