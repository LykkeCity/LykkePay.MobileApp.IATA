//
//  LWPKTransferConfirmationView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPKTransferConfirmationView.h"
#import "LWPKTransferConfirmationCellView.h"
#import "LWPKTransferModel.h"

@interface LWPKTransferConfirmationView() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIButton *cancelButton;
    UIButton *doneButton;
    UILabel *titleLabel;
    
    
    UIView *shadow;
    
    
    NSInteger selectedIndex;
    
    CGFloat firstLineHeight;
    CGFloat secondLineHeight;
    CGFloat thirdLineHeight;
    
    
}

@property (strong, nonatomic) void(^completion)(BOOL);
@property (strong, nonatomic) LWPKTransferModel *transfer;


@end

@implementation LWPKTransferConfirmationView

-(id) init
{
    self=[super init];
    
    UIWindow *parentView=[UIApplication sharedApplication].keyWindow;
    
    selectedIndex=-1;
    
    self.backgroundColor=[UIColor whiteColor];
    
    
    cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"CANCEL" attributes:@{NSKernAttributeName:@(1.2), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]}] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    [self addSubview:cancelButton];
    
//    doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [doneButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"DONE" attributes:@{NSKernAttributeName:@(0.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:14], NSForegroundColorAttributeName:[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1]}] forState:UIControlStateNormal];
//    [doneButton sizeToFit];
//    [doneButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:doneButton];
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:@"SEND TRANSFER" attributes:@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]}];
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    
    tableView=[[UITableView alloc] init];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
    
    shadow=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
    shadow.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    shadow.alpha=0;
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPressed)];
    [shadow addGestureRecognizer:gesture];
    
    [parentView addSubview:shadow];
    [parentView addSubview:self];
    
    self.frame=CGRectMake(0, parentView.bounds.size.height, parentView.bounds.size.width, parentView.bounds.size.height*0.66);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        shadow.alpha=1;
        self.center=CGPointMake(self.center.x, self.center.y-self.bounds.size.height);
    }];
    
    return self;
}

+(void) showTransfer:(LWPKTransferModel *) transfer withCompletion:(void(^)(BOOL result)) completion
{
    LWPKTransferConfirmationView *view=[[LWPKTransferConfirmationView alloc] init];
    view.completion=completion;
    view.transfer=transfer;
}

-(void) orientationChanged
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    self.frame=CGRectMake(0, window.bounds.size.height*0.34, window.bounds.size.width, window.bounds.size.height*0.66);
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    tableView.frame=CGRectMake(0, 78, self.bounds.size.width, self.bounds.size.height-78);
    CGFloat pos=33;
    cancelButton.center=CGPointMake(20+cancelButton.bounds.size.width/2, pos);
    titleLabel.center=CGPointMake(self.bounds.size.width/2, pos);
    doneButton.center=CGPointMake(self.bounds.size.width-doneButton.bounds.size.width/2-20, pos);
}

-(CGFloat) tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==3)
    {
        return tableView.bounds.size.height-(firstLineHeight+secondLineHeight+thirdLineHeight);
    }
    CGFloat height=[(LWPKTransferConfirmationCellView *)[self tableView:tableView cellForRowAtIndexPath:indexPath] heightForWidth:_tableView.bounds.size.width];
    return height;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    LWPKTransferConfirmationCellView *cell=[[LWPKTransferConfirmationCellView alloc] init];
    if(indexPath.row==0)
    {
        cell.leftText=@"Wallet";
        cell.rightText=self.transfer.sourceWallet.name;
        firstLineHeight=[cell heightForWidth:tableView.bounds.size.width];
    }
    else if(indexPath.row==1)
    {
        cell.leftText=@"Wallet address";
        cell.rightText=self.transfer.destinationAddress;
        secondLineHeight=[cell heightForWidth:tableView.bounds.size.width];
    }
    else if(indexPath.row==2)
    {
        cell.leftText=@"Amount";
        cell.rightText=[NSString stringWithFormat:@"%@ %@", self.transfer.asset.name, self.transfer.amount.stringValue];
        thirdLineHeight=[cell heightForWidth:tableView.bounds.size.width];
    }
    else if(indexPath.row==3)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        cell.translatesAutoresizingMaskIntoConstraints=NO;
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        view.translatesAutoresizingMaskIntoConstraints=NO;
        
        UIImageView *fingerPrintView=[[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 60, 60)];
//        fingerPrintView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        fingerPrintView.contentMode=UIViewContentModeCenter;
        fingerPrintView.image=[UIImage imageNamed:@"TransferSignFinger"];
        [view addSubview:fingerPrintView];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 60, 120, 30)];
        label.text=@"Send transfer";
        [view addSubview:label];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[UIColor blackColor];
        
        [cell addSubview:view];
        
        NSLayoutConstraint *width=[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120];
        
        NSLayoutConstraint *height=[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120];

        NSLayoutConstraint *centerX=[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY=[NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        [cell addConstraint:centerX];
        [cell addConstraint:centerY];
        [view addConstraint:width];
        [view addConstraint:height];

        [NSLayoutConstraint activateConstraints:@[centerY, centerX]];
        
        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signPressed)];
        [view addGestureRecognizer:gesture];
        
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) signPressed
{
    [self hideView];
    _completion(YES);
}


//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    selectedIndex=indexPath.row;
//}

-(void) hideView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.center=CGPointMake(self.center.x, self.center.y+self.bounds.size.height);
        shadow.alpha=0;
    } completion:^(BOOL finished){
        [shadow removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}

-(void) cancelPressed
{
    [self hideView];
}

-(void) donePressed
{
    [self hideView];
//    self.completion(selectedIndex);
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end