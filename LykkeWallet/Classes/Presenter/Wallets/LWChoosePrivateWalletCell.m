//
//  LWChoosePrivateWalletCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWChoosePrivateWalletCell.h"
#import "LWPrivateWalletModel.h"
#import "LWImageDownloader.h"

@interface LWChoosePrivateWalletCell()
{
    UIImageView *icon;
    UILabel *label;
    LWPrivateWalletModel *wallet;
    UIImageView *checkmark;
    UIView *line;
}

@end

@implementation LWChoosePrivateWalletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(id) initWithWallet:(LWPrivateWalletModel *) _wallet
{
    self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    wallet=_wallet;
    
    icon=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self addSubview:icon];
    [[LWImageDownloader shared] downloadImageFromURLString:wallet.iconURL shouldAuthenticate:NO withCompletion:^(UIImage *image){
        
        icon.image=image;
    }];
    
    label=[[UILabel alloc] init];
    NSDictionary *attributes=@{NSKernAttributeName:@(1.9), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:16]};
    label.attributedText=[[NSAttributedString alloc] initWithString:[wallet.name uppercaseString]  attributes:attributes];
    [label sizeToFit];
    [self addSubview:label];
    
    checkmark=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    checkmark.image=[UIImage imageNamed:@"CheckMark.png"];
    checkmark.hidden=YES;
    [self addSubview:checkmark];
    
    line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:217.0/255 alpha:1];
    [self addSubview:line];
    
    return self;
}

-(void) layoutSubviews
{
    icon.center=CGPointMake(45, 25);
    label.center=CGPointMake(69+label.bounds.size.width/2, 25);
    checkmark.center=CGPointMake(self.bounds.size.width-35, 25);
    line.frame=CGRectMake(30, self.bounds.size.height-0.5, self.bounds.size.width-60, 0.5);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    checkmark.hidden=!selected;

    // Configure the view for the selected state
}

@end
