//
//  LWSettingsCallSupportTableViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSettingsCallSupportTableViewCell.h"

@interface LWSettingsCallSupportTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@implementation LWSettingsCallSupportTableViewCell

-(void) awakeFromNib
{
    [super awakeFromNib];
    if(_hideIcon)
        _iconView.hidden=YES;
        
}

-(void) setHideIcon:(BOOL)hideIcon
{
    if(hideIcon)
        _iconView.hidden=YES;
}


@end
