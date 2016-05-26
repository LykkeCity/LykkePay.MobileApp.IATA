//
//  LWKeyboardToolbar.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 14.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKeyboardToolbar.h"

@implementation LWKeyboardToolbar

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (LWKeyboardToolbar *)toolbarWithDelegate:(id<LWKeyboardToolbarDelegate>)delegate {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LWKeyboardToolbar"
                                                 owner:nil options:nil];
    LWKeyboardToolbar *toolbar = (LWKeyboardToolbar *)[nib objectAtIndex:0];
    toolbar.keyboardDelegate = delegate;
    return toolbar;
}

- (IBAction)prevClicked:(id)sender {
    if (self.keyboardDelegate
        && [self.keyboardDelegate respondsToSelector:@selector(prevClicked)]) {
        [self.keyboardDelegate prevClicked];
    }
}

- (IBAction)nextClicked:(id)sender {
    if (self.keyboardDelegate
        && [self.keyboardDelegate respondsToSelector:@selector(nextClicked)]) {
        [self.keyboardDelegate nextClicked];
    }
}

@end
