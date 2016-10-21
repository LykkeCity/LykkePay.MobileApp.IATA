//
//  LWExchangeOrderPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeOrderPresenter.h"
#import "LWOrderGraphView.h"

@interface LWExchangeOrderPresenter ()
{
    BOOL topScrollViewFilled;
}

@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScrollViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScrollViewTopConstraint;

@end

@implementation LWExchangeOrderPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    [self adjustThinLines];
    
    topScrollViewFilled=NO;
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(_orderBookBuy)
//    {
//        CGFloat height=(35.0+1)*_orderBookBuy.array.count;
//        [_topScrollView setContentOffset:CGPointMake(0, height-_topScrollView.bounds.size.height) animated:NO];
////        [self.view setNeedsLayout];
//        [_topScrollView.layer removeAllAnimations];
//    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat hhh=(self.view.bounds.size.height-40-10)/2;
    _topScrollViewHeight.constant=hhh;
    
    if(!topScrollViewFilled && _orderBookBuy)
    {
        [self fillTopSubview];
        topScrollViewFilled=YES;
        [self fillBottomScrollView];
        
    }
    
    if(_orderBookBuy)
    {
        CGFloat height=(35.0+1)*_orderBookBuy.array.count;
        if(height<hhh)
        {
            _topScrollViewTopConstraint.constant=hhh-height;
            _topScrollViewHeight.constant=height;
        }
        else
        {
            [_topScrollView setContentOffset:CGPointMake(0, height-_topScrollView.bounds.size.height) animated:NO];
        }
        
        _topScrollView.contentSize=CGSizeMake(_topScrollView.bounds.size.width, height);
        _bottomScrollView.contentSize=CGSizeMake(_bottomScrollView.bounds.size.width, (35.0+1)*_orderBookBuy.array.count);

        
//        [_topScrollView setContentOffset:CGPointMake(0, height-_topScrollView.bounds.size.height) animated:NO];
        //        [self.view setNeedsLayout];
        [_topScrollView.layer removeAllAnimations];
    }

    
}

//-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    if(_orderBookBuy)
//    {
//        CGFloat height=(35.0+1)*_orderBookBuy.array.count;
//        [_topScrollView setContentOffset:CGPointMake(0, height-(size.height-40-10)/2) animated:NO];
//        //        [self.view setNeedsLayout];
//        [_topScrollView.layer removeAllAnimations];
//    }
//
//}

-(void) setOrderBookBuy:(LWOrderBookElementModel *)orderBookBuy
{
    _orderBookBuy=orderBookBuy;
    [self.view setNeedsLayout];
}

-(void) fillTopSubview
{
    CGFloat height=(35.0+1)*_orderBookBuy.array.count;
    
    double max=0;
    double min=MAXFLOAT;
    for(NSDictionary *d in _orderBookBuy.array)
    {
        if([d[@"Volume"] doubleValue]>max)
            max=[d[@"Volume"] doubleValue];
        if([d[@"Volume"] doubleValue]<min)
            min=[d[@"Volume"] doubleValue];
    }

    
    for(NSDictionary *d in _orderBookBuy.array)
    {
        LWOrderGraphView *view=[[LWOrderGraphView alloc] initWithPrice:[d[@"Price"] doubleValue] volume:[d[@"Volume"] doubleValue]];
        view.graphMaxVolume=max;
        view.graphMinVolume=min;
        view.graphColor=[UIColor colorWithRed:1 green:247.0/255 blue:234.0/255 alpha:1];
        view.volumeColor=[UIColor colorWithRed:1 green:174.0/255 blue:44.0/255 alpha:1];
        view.assetPair=self.assetPair;
        view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        view.frame=CGRectMake(0, height-(35.0+1)*([_orderBookBuy.array indexOfObject:d]+1), _topScrollView.bounds.size.width, 35.0);
        [_topScrollView addSubview:view];
        
    }
    _topScrollView.contentSize=CGSizeMake(_topScrollView.bounds.size.width, height);
//    _topScrollView.contentOffset=CGPointMake(0, height-_topScrollView.bounds.size.height);
}

-(void) fillBottomScrollView
{
    
    
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"Price" ascending:NO];
    NSArray *sortDescriptors=[NSArray arrayWithObject:descriptor];
    
    NSArray *aaa=_orderBookSell.array;
    NSArray *array=[_orderBookSell.array sortedArrayUsingDescriptors:sortDescriptors];
    CGFloat height=(35.0+1)*_orderBookSell.array.count;
    
    double max=0;
    double min=MAXFLOAT;
    for(NSDictionary *d in array)
    {
        if([d[@"Volume"] doubleValue]>max)
            max=[d[@"Volume"] doubleValue];
        if([d[@"Volume"] doubleValue]<min)
            min=[d[@"Volume"] doubleValue];

    }
    
    
    for(NSDictionary *d in array)
    {
        LWOrderGraphView *view=[[LWOrderGraphView alloc] initWithPrice:[d[@"Price"] doubleValue] volume:[d[@"Volume"] doubleValue]];
        view.graphMaxVolume=max;
        view.graphMinVolume=min;
        view.graphColor=[UIColor colorWithRed:246.0/255 green:229.0/255 blue:1 alpha:1];
        view.volumeColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
        view.assetPair=self.assetPair;
        view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        view.frame=CGRectMake(0, (35.0+1)*([array indexOfObject:d]), _bottomScrollView.bounds.size.width, 35.0);
        [_bottomScrollView addSubview:view];
        
    }
    _bottomScrollView.contentSize=CGSizeMake(_bottomScrollView.bounds.size.width, height);

}

@end
