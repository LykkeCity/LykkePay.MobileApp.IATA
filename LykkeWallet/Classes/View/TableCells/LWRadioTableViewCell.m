//
//  LWRadioTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRadioTableViewCell.h"


@implementation LWRadioTableViewCell


#pragma mark - Actions

- (IBAction)switchChanged:(id)sender {
    if (self.delegate) {
        [self.delegate switcherChanged:[sender isOn]];
    }
}


#pragma mark - General

- (void)setSwitcherOn:(BOOL)isOn {
    [self.radioSwitch setOn:isOn];
}

@end
