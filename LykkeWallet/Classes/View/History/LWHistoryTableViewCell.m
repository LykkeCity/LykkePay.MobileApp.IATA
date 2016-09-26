//
//  LWHistoryTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWHistoryTableViewCell.h"

@interface LWHistoryTableViewCell()
{
    UIView *line;
    BOOL shouldShowBottomLine;
}

@end

@implementation LWHistoryTableViewCell

-(void) awakeFromNib
{
    line=[[UIView alloc] initWithFrame:CGRectMake(0, 59.5, 1024, 0.5)];
    line.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:line];
}

-(void) setShowBottomLine:(BOOL)showBottomLine
{
    line.hidden=!showBottomLine;
    shouldShowBottomLine=showBottomLine;
}

-(BOOL) showBottomLine
{
    return shouldShowBottomLine;
}

-(void) update
{
    if (_type == LWHistoryItemTypeTrade)
    {
        if(self.volume.doubleValue>0)
            self.typeLabel.text=@"Buy";
        else
            self.typeLabel.text=@"Sell";
        self.typeImageView.hidden=YES;
        
    }
    else if(_type == LWHistoryItemTypeCashInOut)
    {
        if(self.volume.doubleValue>0)
        {
            self.typeLabel.text=@"Cash In";
            self.typeImageView.image=[UIImage imageNamed:@"CashInSwift"];
        }
        else
        {
            self.typeLabel.text=@"Cash Out";
            self.typeImageView.image=[UIImage imageNamed:@"CashOutSwift"];
            
        }
        self.typeImageView.hidden=NO;
        
    }
    else if(_type == LWHistoryItemTypeTransfer)
    {
        if(self.volume.doubleValue>0)
            self.typeLabel.text=@"Incoming transfer";
        else
            self.typeLabel.text=@"Outgoing transfer";
        self.typeImageView.hidden=YES;
    }

}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
}




@end
