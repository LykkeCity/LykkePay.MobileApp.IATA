//
//  LWChoosePrivateWalletView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWChoosePrivateWalletView.h"
#import "LWPrivateWalletsManager.h"
#import "LWChoosePrivateWalletCell.h"
#import "LWPrivateWalletModel.h"
#import "LWCache.h"

@interface LWChoosePrivateWalletView() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIButton *cancelButton;
    UIButton *doneButton;
    UILabel *titleLabel;
    
    
    UIView *shadow;
    
    NSArray *wallets;
    
    LWPrivateWalletModel *selectedWallet;
    LWPrivateWalletModel *tradingWallet;
}

@property (strong, nonatomic) void(^completion)(LWPrivateWalletModel *model);
@property (strong, nonatomic) LWPrivateWalletModel *sourceWallet;

@end

@implementation LWChoosePrivateWalletView

-(id) init
{
    self=[super init];
    
    tradingWallet=[[LWPrivateWalletModel alloc] init];
    tradingWallet.address=[LWCache instance].multiSig;
    tradingWallet.name=@"MY TRADING WALLET";
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"lykke_logo.png" ofType:nil];
    tradingWallet.iconURL=[NSURL fileURLWithPath:path].absoluteString;

    
    UIWindow *parentView=[UIApplication sharedApplication].keyWindow;
    if(parentView.bounds.size.height<300)
        parentView=[UIApplication sharedApplication].windows[1];
    
    wallets=[LWPrivateWalletsManager shared].wallets;
    
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
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:@"WALLETS" attributes:@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]}];
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

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 35)];
    view.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 35)];
    if(section==1 || !_sourceWallet)
    label.text=@"Private wallet";
    else
        label.text=@"Trading wallet";
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    [view addSubview:label];
    
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
    topLine.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [view addSubview:topLine];

    UIView *bottomLine=[[UIView alloc] initWithFrame:CGRectMake(0, 34.5, 1024, 0.5)];
    bottomLine.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [view addSubview:bottomLine];

    return view;
}

-(void) setSourceWallet:(LWPrivateWalletModel *)sourceWallet
{
    _sourceWallet=sourceWallet;
    NSMutableArray *filtered=[[NSMutableArray alloc] init];
    for(LWPrivateWalletModel *m in wallets)
    {
        if([m.address isEqualToString:sourceWallet.address]==NO)
            [filtered addObject:m];
    }
    wallets=filtered;
}

+(void) showWithCurrentWallet:(LWPrivateWalletModel *)current completion:(void(^)(LWPrivateWalletModel *)) completion
{
    LWChoosePrivateWalletView *view=[[LWChoosePrivateWalletView alloc] init];
    view.completion=completion;
    view.sourceWallet=current;
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(wallets.count && _sourceWallet)
        return 2;
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0 && _sourceWallet)
        return 1;
    return wallets.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LWChoosePrivateWalletCell *cell;
    if(indexPath.section==0 && _sourceWallet)
    {
        cell=[[LWChoosePrivateWalletCell alloc] initWithWallet:tradingWallet];
    }
    else
    {
        cell=[[LWChoosePrivateWalletCell alloc] initWithWallet:wallets[indexPath.row]];
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((wallets.count==0 || (wallets.count>0 && indexPath.section==0)) && _sourceWallet)
        selectedWallet=tradingWallet;
    else
        selectedWallet=wallets[indexPath.row];
    
    [self donePressed];
}

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
    self.completion(selectedWallet);
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
