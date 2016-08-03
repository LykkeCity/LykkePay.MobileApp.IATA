//
//  LWPrivateWalletTitleCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletTitleCell.h"
#import "LWImageDownloader.h"

@interface LWPrivateWalletTitleCell()
{
    UIImageView *iconImageView;
    UILabel *titleLabel;
    UIImageView *disclosureImageView;
}

@end

@implementation LWPrivateWalletTitleCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setWallet:(LWPrivateWalletModel *)wallet
{
    iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self addSubview:iconImageView];
    
    [[LWImageDownloader shared] downloadImageFromURLString:wallet.iconURL withCompletion:^(UIImage *image){
    
        iconImageView.image=image;
    }];
    
    
    titleLabel=[[UILabel alloc] init];
    
    NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1],
                               NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:16],
                               NSKernAttributeName:@(1.9)};
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:wallet.name attributes:attributes];
    [self addSubview:titleLabel];
    
    disclosureImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PrivateWalletTitleDisclosure"]];
    disclosureImageView.frame=CGRectMake(0, 0, 8, 14);
    [self addSubview:disclosureImageView];
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
    lineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:lineView];
    
    lineView=[[UIView alloc] initWithFrame:CGRectMake(0, [LWPrivateWalletTitleCell height]-0.5, 1024, 0.5)];
    lineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:lineView];

}

-(void) layoutSubviews
{
    [super layoutSubviews];
    iconImageView.center=CGPointMake(25+15, self.bounds.size.height/2);
    titleLabel.frame=CGRectMake(62, 0, self.bounds.size.width-45-62, self.bounds.size.height);
    disclosureImageView.center=CGPointMake(self.bounds.size.width-32, self.bounds.size.height/2);
}

+(CGFloat) height
{
    return 52;
}




@end
