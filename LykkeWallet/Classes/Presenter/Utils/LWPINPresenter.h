//
//  LWPINPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
typedef enum {PIN_TYPE_CHECK, PIN_TYPE_ENTER} PIN_TYPE;

@interface LWPINPresenter : LWAuthComplexPresenter

@property PIN_TYPE pinType;

@property (nonatomic, copy) void (^finishBlock)(BOOL, NSString *pin);

@property (nonatomic, copy) BOOL (^checkBlock)(NSString *pin);

@property (nonatomic, copy) void (^successBlock)(void);

@end
