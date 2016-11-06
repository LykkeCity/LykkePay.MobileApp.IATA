//
//  LWPinKeyboardView.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 17.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKView.h"


@protocol LWPinKeyboardViewDelegate
@required
- (void)pinEntered:(NSString *)pin;
- (void)pinCanceled;
- (void)pinAttemptEnds;

@end


@interface LWPinKeyboardView : TKView {
    
}

@property (weak, nonatomic) id<LWPinKeyboardViewDelegate> delegate;

- (void)updateView;
- (void)pinRejected;
- (void)setTitle:(NSString *)title;

@end
