//
//  TKContainer.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKContainer.h"


@implementation TKContainer


#pragma mark - Root

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
}


#pragma mark - Common

- (void)attach:(TKView *)view {
    // clear subviews
    if (self.contentView) {
        [self.contentView removeFromSuperview];
        _contentView = nil;
    }
    _contentView = view;
    // add new with frame adjusting
    [self.contentView setFrame:self.bounds];
    [self addSubview:self.contentView];
}

@end
