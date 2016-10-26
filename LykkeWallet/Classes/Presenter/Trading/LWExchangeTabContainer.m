//
//  LWExchangeTabContainer.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeTabContainer.h"
#import "LWExchangeFormPresenter.h"
#import "LWTradingLinearGraphPresenter.h"
#import "LWExchangeOrderPresenter.h"
#import "LWPacketOrderBook.h"
#import "LWAssetPairModel.h"


@interface LWExchangeTabContainer ()
{
    LWExchangeOrderPresenter *order;
    LWExchangeFormPresenter *asset;
    LWTradingLinearGraphPresenter *chart;
    NSArray *controllers;
    UIViewController *currentController;
    NSArray *labels;
    NSArray *labelTitles;
    
    NSDictionary *tabLabelActiveAttributes;
    NSDictionary *tabLabelInactiveAttributes;
    
}

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *assetLabel;
@property (weak, nonatomic) IBOutlet UILabel *chartLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectorLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *selectorView;

@property (strong, nonatomic) IBOutlet UIView *topBarTitleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LWExchangeTabContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tabLabelActiveAttributes=@{NSKernAttributeName:@(1.1), NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:13]};
    tabLabelInactiveAttributes=@{NSKernAttributeName:@(1.1), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:13]};
    
    order=[self controllerFromClass:[LWExchangeOrderPresenter class]];
    asset=[self controllerFromClass:[LWExchangeFormPresenter class]];
    chart=[self controllerFromClass:[LWTradingLinearGraphPresenter class]];
    
    controllers=@[asset, chart, order];
    labels=@[_assetLabel, _chartLabel, _orderLabel];
    labelTitles=@[@"ASSET", @"CHART", @"ORDERS"];
    
    for(UILabel *l in labels)
    {
        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabPressed:)];
        [l addGestureRecognizer:gesture];
        l.userInteractionEnabled=YES;
        l.attributedText=[[NSAttributedString alloc] initWithString:labelTitles[[labels indexOfObject:l]] attributes:tabLabelInactiveAttributes];
    }
    
    if(_tabToShow==TAB_ASSET)
    {
        [_container bringSubviewToFront:asset.view];
        currentController=asset;
        
        _assetLabel.attributedText=[[NSAttributedString alloc] initWithString:labelTitles[0] attributes:tabLabelActiveAttributes];
        _assetLabel.textColor=[UIColor whiteColor];
    }
    else if(_tabToShow==TAB_GRAPH)
    {
        [_container bringSubviewToFront:chart.view];
        currentController=chart;
        
        _chartLabel.attributedText=[[NSAttributedString alloc] initWithString:labelTitles[1] attributes:tabLabelActiveAttributes];
        _chartLabel.textColor=[UIColor whiteColor];

        _selectorLeftConstraint.constant=107;
    }
    [self.view layoutSubviews];
    _selectorView.layer.cornerRadius=_selectorView.bounds.size.height/2;
    
    NSString *name=self.assetPair.name;
    if(self.assetPair.inverted)
    {
        NSArray *arr=[name componentsSeparatedByString:@"/"];
        if(arr.count==2)
            name=[NSString stringWithFormat:@"%@/%@", arr[1], arr[0]];
    }
    
    NSDictionary *titleAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};

    _titleLabel.attributedText=[[NSAttributedString alloc] initWithString:name attributes:titleAttributes];

    _selectorView.backgroundColor=[UIColor colorWithRed:171.0/255 green:0 blue:255 alpha:1];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) tabPressed:(UITapGestureRecognizer *) gesture
{
    UILabel *label=(UILabel *)gesture.view;
    [self switchToController:controllers[[labels indexOfObject:label]]];
}

-(id) controllerFromClass:(Class) class
{
    LWExchangeOrderPresenter *ccc=[class new];
    [_container addSubview:ccc.view];
    ccc.view.frame=_container.bounds;
    ccc.assetPair=self.assetPair;
    ccc.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:ccc];
    return ccc;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBackButton];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
    [self.navigationController.view addSubview:_topBarTitleView];
//    CGRect rrr=CGRectMake(200, 0, 200, _topBarTitleView.bounds.size.height);
        CGRect rrr=CGRectMake(60, 0, self.navigationController.view.bounds.size.width-120, _topBarTitleView.bounds.size.height);
    _topBarTitleView.frame=rrr;
//    _topBarTitleView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    }

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_topBarTitleView removeFromSuperview];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [LWAuthManager instance].caller=self;
    [[LWAuthManager instance] requestOrderBook:self.assetPair.identity];
}


-(void) authManager:(LWAuthManager *)manager didGetOrderBook:(LWPacketOrderBook *)packet
{
    if(self.assetPair.inverted)
    {
        [packet.buyOrders invert];
        [packet.sellOrders invert];
        order.orderBookBuy=packet.sellOrders;
        order.orderBookSell=packet.buyOrders;
        
    }
    else
    {
        order.orderBookBuy=packet.buyOrders;
        order.orderBookSell=packet.sellOrders;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchToController:(UIViewController *) controller
{
    if(controller==currentController)
        return;
    
    int index=[controllers indexOfObject:controller];
    int direction=index-[controllers indexOfObject:currentController];
    direction=direction/abs(direction);
    
    controller.view.center=CGPointMake(self.view.bounds.size.width*(0.5+direction), controller.view.center.y);
    
    self.view.userInteractionEnabled=NO;
    
    [self transitionFromViewController:currentController toViewController:controller duration:0.5 options:0 animations:^{
        controller.view.frame=_container.bounds;
        currentController.view.center=CGPointMake(self.view.bounds.size.width*(0.5-direction), currentController.view.center.y);
    } completion:^(BOOL finished){
        [_container bringSubviewToFront:controller.view];
        currentController.view.frame=_container.bounds;
        [controller didMoveToParentViewController:self];
        self.view.userInteractionEnabled=YES;
        
    }];
    
//    _buyButtonLabel.alpha=0;
//    _transferButtonLabel.alpha=0;
//
    
    _selectorLeftConstraint.constant=[controllers indexOfObject:controller]*(101+6);
    
    [UIView animateWithDuration:0.3 animations:^{
//        _buyButtonLabel.alpha=1;
//        _transferButtonLabel.alpha=1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
//        _selectorLeftConstraint.constant=[controllers indexOfObject:controller]*(101+6);
//        [UIView animateWithDuration:0.2 animations:^{
//            [self.view layoutIfNeeded];
//        }];
        
    }];
    
    currentController=controller;
    for(UILabel *l in labels)
    {
//        l.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        l.attributedText=[[NSAttributedString alloc] initWithString:labelTitles[[labels indexOfObject:l]] attributes:tabLabelInactiveAttributes];
    }
    
    [labels[index] setAttributedText:[[NSAttributedString alloc] initWithString:labelTitles[index] attributes:tabLabelActiveAttributes]];
    
    [labels[index] setTextColor:[UIColor whiteColor]];
    
    
//    _transferButtonLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
//    _buyButtonLabel.textColor=[UIColor whiteColor];
    
}




@end
