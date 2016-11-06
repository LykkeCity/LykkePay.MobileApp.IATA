//
//  LWLykkeTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 28.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWLykkeTableViewCell.h"


@implementation LWLykkeTableViewCell {
    
}


#pragma mark - Identity

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self.class reuseIdentifier] bundle:[NSBundle mainBundle]];
}

- (IBAction)addItemClicked:(id)sender {
    [self.cellDelegate addLykkeItemClicked:self];
}

@end
