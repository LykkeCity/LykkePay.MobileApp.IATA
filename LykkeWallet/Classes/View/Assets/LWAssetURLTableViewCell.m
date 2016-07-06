//
//  LWAssetURLTableViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetURLTableViewCell.h"

@implementation LWAssetURLTableViewCell

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.userInteractionEnabled=YES;
    self.contentView.userInteractionEnabled=YES;
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionURLPressed:)];
    [self.urlButton addGestureRecognizer:gesture];
}

-(IBAction)descriptionURLPressed:(id)sender
{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlButton.titleLabel.text]];
}
@end
