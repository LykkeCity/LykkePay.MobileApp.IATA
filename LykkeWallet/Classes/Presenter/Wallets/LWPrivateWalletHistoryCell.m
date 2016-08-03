//
//  LWPrivateWalletHistoryCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPrivateWalletHistoryCell.h"
#import "LWPrivateWalletHistoryCellModel.h"

#define TEXT_COLOR [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]

@interface LWPrivateWalletHistoryCell()
{
    LWPrivateWalletHistoryCellModel *model;
    
    UIImageView *icon;
    UILabel *titleLabel;
    UILabel *dateLabel;
    UILabel *priceLabel;
    UILabel *priceSmallLabel;
    UIView *lineView;
}

@end

@implementation LWPrivateWalletHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id) initWithModel:(LWPrivateWalletHistoryCellModel *)_model
{
    self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    model=_model;
    
    icon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WalletBitcoin"]];
    icon.frame=CGRectMake(0, 0, 25, 25);
    [self addSubview:icon];
    
    ;
    
    priceLabel=[[UILabel alloc] init];
    priceLabel.text=[NSString stringWithFormat:@"%f", model.amount.floatValue];
    priceLabel.font=[UIFont fontWithName:@"ProximaNova-Light" size:22.5];
    priceLabel.textColor=[UIColor colorWithRed:1 green:62.0/255 blue:46.0/255 alpha:1];
    [priceLabel sizeToFit];
    [self addSubview:priceLabel];
    
    titleLabel=[[UILabel alloc] init];
    
    if(model.type==LWPrivateWalletTransferTypeSend)
        titleLabel.text=@"Send Transfer";
    else
        titleLabel.text=@"Receive Transfer";
    titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    titleLabel.textColor=TEXT_COLOR;
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    dateLabel=[[UILabel alloc] init];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateLabel.text=[formatter stringFromDate:model.date];
    dateLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:12];
    dateLabel.textColor=TEXT_COLOR;
    dateLabel.alpha=0.6;
    [dateLabel sizeToFit];
    [self addSubview:dateLabel];
    
    priceSmallLabel=[[UILabel alloc] init];
    priceSmallLabel.textColor=dateLabel.textColor;
    priceSmallLabel.font=dateLabel.font;
    priceSmallLabel.text=model.baseAssetAmount.stringValue;
    priceSmallLabel.alpha=dateLabel.alpha;
    [priceSmallLabel sizeToFit];
    [self addSubview:priceSmallLabel];
    
    lineView=[[UIView alloc] init];
    lineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:lineView];

    
    
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    icon.center=CGPointMake(33+icon.bounds.size.width/2, 10+icon.bounds.size.height/2);
    titleLabel.center=CGPointMake(69+titleLabel.bounds.size.width/2, 10+titleLabel.bounds.size.height/2);
    dateLabel.center=CGPointMake(69+dateLabel.bounds.size.width/2, 35+dateLabel.bounds.size.height/2);
    priceLabel.center=CGPointMake(self.bounds.size.width-30-priceLabel.bounds.size.width/2, 8.5+priceLabel.bounds.size.height/2);
    priceSmallLabel.center=CGPointMake(self.bounds.size.width-30-priceSmallLabel.bounds.size.width/2, 35+priceSmallLabel.bounds.size.height/2);
    lineView.frame=CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5);
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
