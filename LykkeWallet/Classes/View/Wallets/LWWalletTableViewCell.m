//
//  LWWalletTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWWalletTableViewCell.h"


@interface LWWalletTableViewCell () {
    
}

@end


@implementation LWWalletTableViewCell


#pragma mark - Actions

- (IBAction)plusClicked:(id)sender {
    [self.delegate addWalletClicked:self];
}

@end
