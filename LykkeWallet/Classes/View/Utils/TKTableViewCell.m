//
//  TKTableViewCell.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"

@interface TKTableViewCell()
{
    UIImageView *checkmarkView;
    UIImageView *disclosureIndicatorView;
}

@end


@implementation TKTableViewCell


#pragma mark - Identity

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self.class reuseIdentifier] bundle:[NSBundle mainBundle]];
}

-(void) createDisclosureIndicator
{
    disclosureIndicatorView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    disclosureIndicatorView.image=[UIImage imageNamed:@"DisclosureIndicator.png"];
    [self addSubview:disclosureIndicatorView];

}

-(void) awakeFromNib
{
    if(self.accessoryType==UITableViewCellAccessoryDisclosureIndicator && [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        self.accessoryType=UITableViewCellAccessoryNone;
        [self createDisclosureIndicator];
    }
}

-(void) setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if(accessoryType!=UITableViewCellAccessoryCheckmark)
    {
        [super setAccessoryType:accessoryType];
        checkmarkView.hidden=YES;
        return;
    }
    
    
    if(!checkmarkView)
    {
        checkmarkView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        checkmarkView.image=[UIImage imageNamed:@"CheckMark.png"];
        [self addSubview:checkmarkView];
    }
    checkmarkView.hidden=NO;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        checkmarkView.center=CGPointMake(self.bounds.size.width-checkmarkView.bounds.size.width/2, self.bounds.size.height/2);
    else
    {
        checkmarkView.center=CGPointMake(self.bounds.size.width/2+704/2-checkmarkView.bounds.size.width/2, self.bounds.size.height/2);
    }
    
    
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        checkmarkView.center=CGPointMake(self.bounds.size.width-checkmarkView.bounds.size.width/2, self.bounds.size.height/2);
        disclosureIndicatorView.center=CGPointMake(self.bounds.size.width-disclosureIndicatorView.bounds.size.width/2, self.bounds.size.height/2);

    }
    else
    {
        checkmarkView.center=CGPointMake(self.bounds.size.width/2+704/2-checkmarkView.bounds.size.width/2, self.bounds.size.height/2);
        disclosureIndicatorView.center=CGPointMake(self.bounds.size.width/2+704/2-disclosureIndicatorView.bounds.size.width/2, self.bounds.size.height/2);
    }

}

@end
