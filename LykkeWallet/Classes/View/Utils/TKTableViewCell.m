//
//  TKTableViewCell.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


@implementation TKTableViewCell


#pragma mark - Identity

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self.class reuseIdentifier] bundle:[NSBundle mainBundle]];
}

@end
