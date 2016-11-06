//
//  LWPinKeyboardView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 17.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPinKeyboardView.h"
#import "LWConstants.h"
#import "Macro.h"
#import "UIColor+Generic.h"


@interface LWPinKeyboardView () {
    NSString *pin;
    int       attemptsRemaining;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIView *numpadView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numpadButtons;


#pragma mark - Actions

- (IBAction)numpadButtonClick:(UIButton *)sender;


#pragma mark - Utils

- (void)resetPin;
- (void)updatePinStatus;

@end


@implementation LWPinKeyboardView


static NSInteger const kPinLength = 4;
static NSInteger const kAttemptsAvailable = 3;


- (void)updateView {
    attemptsRemaining = kAttemptsAvailable;
    
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:kMainDarkElementsColor] forState:UIControlStateNormal];
    
    [self setTitle:Localize(@"ABPadLockScreen.pin.enter")];
    [self.cancelButton setTitle:Localize(@"exchange.assets.modal.cancel")
                       forState:UIControlStateNormal];
    
    [self resetPin];
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

- (void)pinRejected {
    --attemptsRemaining;
    if (attemptsRemaining > 0) {
        NSString *attempts = Localize(@"ABPadLockScreen.pin.attempts.left.one");
        if (attemptsRemaining != 1) {
            attempts = Localize(@"ABPadLockScreen.pin.attempts.left.several");
        }

        NSString *title = [NSString stringWithFormat:@"%d %@", attemptsRemaining, attempts];
        [self setTitle:title];
    }
    else {
        [self.delegate pinAttemptEnds];
    }
    
    [self resetPin];
}


#pragma mark - Actions

- (IBAction)cancelClicked:(id)sender {
    [self.delegate pinCanceled];
}

- (IBAction)backspaceClicked:(id)sender {
    if (pin.length > 0) {
        pin = [pin substringToIndex:pin.length - 1];
        
        [self updatePinStatus];
    }
}

- (IBAction)numpadButtonClick:(UIButton *)sender {
    NSString *number = sender.titleLabel.text;
    if (number && pin.length < kPinLength) {
        pin = [pin stringByAppendingString:number];
        [self updatePinStatus];
    }
}


#pragma mark - Utils

- (void)resetPin {
    pin = @"";
    [self updatePinStatus];
}

- (void)updatePinStatus {
    
    NSString *imageName = @"";
    switch (pin.length) {
        case 1: {
            imageName = @"PinStatus1";
            break;
        }
        case 2: {
            imageName = @"PinStatus2";
            break;
        }
        case 3: {
            imageName = @"PinStatus3";
            break;
        }
        case 4: {
            imageName = @"PinStatus4";
            break;
        }
        default:
            imageName = @"PinStatus0";
            break;
    }
    
    [self.statusImageView setImage:[UIImage imageNamed:imageName]];
    
    if (pin.length == kPinLength) {
        [self.delegate pinEntered:pin];
    }
}

@end
