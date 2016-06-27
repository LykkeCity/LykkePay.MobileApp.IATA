//
//  LWRefundTableViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/06/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefundTableViewCell.h"
#import "LWRefundAfterView.h"
#import "LWRefundAddressView.h"
#import "LWCache.h"



@interface LWRefundTableViewCell() <LWRefundAddressViewDelegate>
{
    LWRefundAfterView *afterView;
    UIView *topLine;
    UIView *bottomLine;
    UIButton *changeButton;
    LWRefundAddressView *addressView;
    
    UIImageView *disclosureImage;
    RefundCellType cellType;
}

@end

@implementation LWRefundTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id) initWithType:(RefundCellType) type width:(CGFloat) width
{
    self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    _addressString=@"";
    cellType=type;
    self.clipsToBounds=YES;
    self.backgroundColor=[UIColor whiteColor];
    if(type==RefundCellTypeInfo)
    {
        self.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];

        _titleLabel=[self createLabel];
        _titleLabel.frame=CGRectMake(30, 0, width-30, [self height]);
        [self addSubview:_titleLabel];
        bottomLine=[self lineView];
        topLine=[self lineView];
        
        topLine.frame=CGRectMake(0, 0, width, 0.5);
        bottomLine.frame=CGRectMake(0, [self height]-0.5, width, 0.5);
        
        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped)];
        [self addGestureRecognizer:gesture];
    }
    else if(type==RefundCellTypeAfter)
    {
        afterView=[[LWRefundAfterView alloc] init];
        afterView.frame=CGRectMake(0, 0, width, [self height]);
        [self addSubview:afterView];
    }
    else if(type==RefundCellTypeAddress)
    {
        addressView=[[LWRefundAddressView alloc] init];
        addressView.frame=CGRectMake(0, 0, width, [self height]);
        addressView.delegate=self;
        addressView.address=[LWCache instance].refundAddress;
        [self addSubview:addressView];
    }
    
    
    
    return self;
}

-(void) setDaysValidAfter:(int)daysValidAfter
{
    afterView.daysValidAfter=daysValidAfter;
}

-(void) setSendAutomatically:(BOOL)sendAutomatically
{
    afterView.sendAutomatically=sendAutomatically;
}

-(int) daysValidAfter
{
    return afterView.daysValidAfter;
}

-(BOOL) sendAutomatically
{
    return afterView.sendAutomatically;
}

-(void) showChangeButton
{
    if(!changeButton)
    {
        changeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [changeButton addTarget:self action:@selector(changeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [changeButton setTitle:@"Change" forState:UIControlStateNormal];
        changeButton.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
        [changeButton setTitleColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5] forState:UIControlStateNormal];
        [changeButton sizeToFit];
        changeButton.frame=CGRectMake(0, 0, changeButton.bounds.size.width+20, 30);
        
        [self addSubview:changeButton];
    }
    

    changeButton.hidden=NO;
    
    changeButton.center=CGPointMake(self.bounds.size.width-changeButton.bounds.size.width/2-30, self.bounds.size.height/2);

}

-(void) hideChangeButton
{
    changeButton.hidden=YES;
}

-(void) addDisclosureImage
{
    disclosureImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ButtonSelectMark"]];
    disclosureImage.frame=CGRectMake(0, 0, 20, 20);
    disclosureImage.center=CGPointMake(self.bounds.size.width-30-disclosureImage.bounds.size.width/2, self.bounds.size.height/2);
    [self addSubview:disclosureImage];
    
}

-(void) setAddressString:(NSString *)addressString
{
    addressView.address=addressString;
//    if(addressString.length)
//    {
//        addressView.isOpened=NO;
//    }
//    else
//        addressView.isOpened=YES;
}



-(void) layoutSubviews
{
    [super layoutSubviews];
    
    afterView.frame=self.bounds;
    addressView.frame=self.bounds;
    topLine.frame=CGRectMake(0, 0, self.bounds.size.width, 0.5);
    bottomLine.frame=CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5);
    _titleLabel.frame=CGRectMake(30, 0, self.bounds.size.width-30, self.bounds.size.height);
    
    changeButton.center=CGPointMake(self.bounds.size.width-changeButton.bounds.size.width/2-30, self.bounds.size.height/2);
    disclosureImage.center=CGPointMake(self.bounds.size.width-30-disclosureImage.bounds.size.width/2, self.bounds.size.height/2);

}

-(void) changeButtonPressed
{
    [self.delegate addressCellPressedChange];
}

-(void) openAddressCell
{
    addressView.isOpened=YES;
}

-(UIView *) lineView
{
    UIView *view=[[UIView alloc] init];
    view.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [self addSubview:view];
    return view;
}

-(CGFloat) height
{
    if(cellType==RefundCellTypeAfter)
        return 100;
    if(cellType==RefundCellTypeAddress)
    {
        if(addressView.isOpened)
            return 196;
        else
            return 50;
    }
    return 50;
}

-(UILabel *) createLabel
{
    UILabel *label=[[UILabel alloc] init];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    label.textColor=[UIColor colorWithRed:53.0/255 green:76.0/255 blue:97.0/255 alpha:1];
    label.backgroundColor=nil;
    label.opaque=NO;
    return label;
}

-(void) addressViewPressedApply:(LWRefundAddressView *)view
{
    [self.delegate addressViewPressedApplyOnCell:self];
}

-(void) cellTapped
{
    [self.delegate cellTapped:self];
}

-(void) addressViewScanQRCode:(LWRefundAddressView *)view
{
    [self.delegate addressViewPressedScanQRCode:self];
}




@end
