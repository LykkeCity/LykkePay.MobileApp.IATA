//
//  LWBitcoinTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBitcoinTableViewCell.h"


@implementation LWBitcoinTableViewCell


#pragma mark - Identity

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self.class reuseIdentifier] bundle:[NSBundle mainBundle]];
}


#pragma mark - Actions

- (IBAction)onPlusClicked:(id)sender {
    [self.cellDelegate addBitcoinClicked:self];
}

@end
