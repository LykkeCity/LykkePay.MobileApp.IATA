//
//  LWRadioTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRadioTableViewCell.h"


@implementation LWRadioTableViewCell

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.radioSwitch.tintColor=[UIColor colorWithRed:199.0/255 green:203.0/255 blue:209.0/255 alpha:1];
    self.radioSwitch.backgroundColor=[UIColor colorWithRed:199.0/255 green:203.0/255 blue:209.0/255 alpha:1];
    self.radioSwitch.layer.cornerRadius = 16.0;

}

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
