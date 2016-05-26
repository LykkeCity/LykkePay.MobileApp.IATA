//
//  TKView.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKView.h"


@implementation TKView


#pragma mark - Root

- (instancetype)init {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
}


#pragma mark - Update

- (void)reloadData {
    // override if necessary
}

@end
