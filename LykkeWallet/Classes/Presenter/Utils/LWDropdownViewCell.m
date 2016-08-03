//
//  LWDropdownViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWDropdownViewCell.h"

@interface LWDropdownViewCell()
{
    
    UILabel *label;
    
    UIImageView *checkmark;
    UIView *line;
    NSString *title;
}

@end

@implementation LWDropdownViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(id) initWithTitle:(NSString *) _title
{
    self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    title=_title;
    
    
    label=[[UILabel alloc] init];
    NSDictionary *attributes=@{NSKernAttributeName:@(1.9), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:16]};
    label.attributedText=[[NSAttributedString alloc] initWithString:title attributes:attributes];
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
    
    label.center=CGPointMake(30+label.bounds.size.width/2, 25);
    checkmark.center=CGPointMake(self.bounds.size.width-35, 25);
    line.frame=CGRectMake(30, self.bounds.size.height-0.5, self.bounds.size.width-60, 0.5);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    checkmark.hidden=!selected;
    
    // Configure the view for the selected state
}

@end