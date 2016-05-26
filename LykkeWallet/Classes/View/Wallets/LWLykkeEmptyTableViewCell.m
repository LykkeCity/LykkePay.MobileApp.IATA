//
//  LWLykkeEmptyTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWLykkeEmptyTableViewCell.h"


@implementation LWLykkeEmptyTableViewCell

- (IBAction)plusClicked:(id)sender {
    [self.delegate addLykkeClicked:self];
}

@end
