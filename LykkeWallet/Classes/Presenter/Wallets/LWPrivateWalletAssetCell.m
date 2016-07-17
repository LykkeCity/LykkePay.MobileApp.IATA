//
//  LWPrivateWalletAssetCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletAssetCell.h"

@interface LWPrivateWalletAssetCell()
{
    UILabel *titleLabel;
    UILabel *baseAssetSumLabel;
    UILabel *sumLabel;
    UIView *lineView;
}

@end

@implementation LWPrivateWalletAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setAsset:(LWPrivateWalletAssetModel *)asset
{
    titleLabel=[[UILabel alloc] init];
    NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1],
                               NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14]};
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:asset.name attributes:attributes];
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    baseAssetSumLabel=[[UILabel alloc] init];
    NSDictionary *attributes1=@{NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6],
                 NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:13]};
    baseAssetSumLabel.attributedText=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"$ %.2f", asset.baseAssetAmount.floatValue] attributes:attributes1];
    [baseAssetSumLabel sizeToFit];
    [self addSubview:baseAssetSumLabel];
    
    sumLabel=[[UILabel alloc] init];
    sumLabel.attributedText=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %.2f", asset.assetId, asset.amount.floatValue] attributes:attributes];
    [sumLabel sizeToFit];
    [self addSubview:sumLabel];
    
    if(!lineView)
    {
        lineView=[[UIView alloc] initWithFrame:CGRectMake(30, [LWPrivateWalletAssetCell height]-0.5, 1024, 0.5)];
        lineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
        [self addSubview:lineView];
    }

}

-(void) addBottomLine
{
    if(lineView)
        [lineView removeFromSuperview];
    lineView=[[UIView alloc] initWithFrame:CGRectMake(0, [LWPrivateWalletAssetCell height]-0.5, 1024, 0.5)];
    lineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:lineView];

}

+(CGFloat) height
{
    return 40;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    titleLabel.center=CGPointMake(titleLabel.bounds.size.width/2+30, self.bounds.size.height/2);
    baseAssetSumLabel.center=CGPointMake(self.bounds.size.width-115-baseAssetSumLabel.bounds.size.width/2, self.bounds.size.height/2);
    sumLabel.center=CGPointMake(self.bounds.size.width-30-sumLabel.bounds.size.width/2, self.bounds.size.height/2);
    
}

@end
