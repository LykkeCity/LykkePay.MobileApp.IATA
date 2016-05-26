//
//  LWKeyboardToolbar.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 14.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LWKeyboardToolbarDelegate <NSObject>

@required
- (void)nextClicked;
- (void)prevClicked;

@end


@interface LWKeyboardToolbar : UIToolbar {
    
}

+ (LWKeyboardToolbar *)toolbarWithDelegate:(id<LWKeyboardToolbarDelegate>)delegate;

@property (weak, nonatomic) id<LWKeyboardToolbarDelegate> keyboardDelegate;

@end
