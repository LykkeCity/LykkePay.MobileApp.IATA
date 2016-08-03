//
//  LWPWTransferInputView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWPrivateWalletModel;

@interface LWPWTransferInputView : UIView

@property (strong, nonatomic) NSString *currencySymbol;
@property int accuracy;

@property (strong, nonatomic) NSString *amountString;

@property (strong, nonatomic) UITextField *textField;

@end
