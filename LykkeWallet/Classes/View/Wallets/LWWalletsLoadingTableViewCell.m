//
//  LWWalletsLoadingTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletsLoadingTableViewCell.h"
#import "LWProgressView.h"

@interface LWWalletsLoadingTableViewCell()

@property (weak, nonatomic) IBOutlet LWProgressView *activity;

@end

@implementation LWWalletsLoadingTableViewCell



-(void) layoutSubviews
{
    [super layoutSubviews];
    [self.activity startAnimating];
}

@end
