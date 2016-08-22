//
//  LWPINButtonView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPINButtonView : UIView

@property id delegate;

@end

@protocol LWPINButtonViewDelegate

-(void) pinButtonViewPressedButtonWithSymbol:(NSString *) symbol;
-(void) pinButtonViewPressedDelete;
-(void) pinButtonPressedFingerPrint;

@end
