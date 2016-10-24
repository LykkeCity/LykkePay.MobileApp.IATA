//
//  LWExchangeOrderPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeOrderPresenter.h"
#import "LWOrderGraphView.h"

@interface LWExchangeOrderPresenter () <UIScrollViewDelegate>
{
    BOOL topScrollViewFilled;
    double maxOrderValue;
    double minOrderValue;
    
    UIView *statusBarView;
    CGFloat distToPopWindow;
    
    CGFloat origTopScrollOffset;
    
    NSTimer *timer;
    
    float velocity;
    CGFloat normalTopScrollViewHeight;
    
    float prevMove;
    int prevSameCount;
    
    BOOL flagStartedScroll;
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
    prevSameCount=0;
    
    _topScrollView.delegate=self;
    _topScrollView.layer.shouldRasterize=YES;
    _topScrollView.layer.rasterizationScale= [UIScreen mainScreen].scale;
    
    topScrollViewFilled=NO;
    
//    self.view.layer.shouldRasterize = YES;
//    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    

//    _topScrollView.bounces=NO;
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    flagStartedScroll=NO;
//    if(_orderBookBuy)
//    {
//        CGFloat height=(35.0+1)*_orderBookBuy.array.count;
//        [_topScrollView setContentOffset:CGPointMake(0, height-_topScrollView.bounds.size.height) animated:NO];
////        [self.view setNeedsLayout];
//        [_topScrollView.layer removeAllAnimations];
//    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

//    topScrollViewFilled=NO;
    
    distToPopWindow=0;
//    [self.view layoutIfNeeded];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        UIWindow *window=self.view.window;
        statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.bounds.size.width, 20)];
        statusBarView.backgroundColor=[UIColor whiteColor];
        [window addSubview:statusBarView];
        
    }
    

}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    flagStartedScroll=YES;
    [scrollView.layer removeAllAnimations];
    [_bottomScrollView.layer removeAllAnimations];
    [timer invalidate];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view.window setFrame:[UIScreen mainScreen].bounds];
    [statusBarView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat hhh=(self.view.bounds.size.height-40-10)/2;
    
//    CGFloat hhh1=[self topScrollHeight];
//    if(distToPopWindow!=0)
    if(!topScrollViewFilled)
    {
        _topScrollViewHeight.constant=hhh;
        [_topScrollView setContentOffset:CGPointMake(0, _topScrollView.contentSize.height-_topScrollView.bounds.size.height) animated:NO];
        [_topScrollView layoutIfNeeded];
        [self.view.layer removeAllAnimations];

    }
    if(!topScrollViewFilled && _orderBookBuy)
    {
        _topScrollViewHeight.constant=hhh;

        maxOrderValue=0;
        minOrderValue=MAXFLOAT;
        for(NSDictionary *d in _orderBookBuy.array)
        {
            if([d[@"Volume"] doubleValue]>maxOrderValue)
                maxOrderValue=[d[@"Volume"] doubleValue];
            if([d[@"Volume"] doubleValue]<minOrderValue)
                minOrderValue=[d[@"Volume"] doubleValue];
        }
        for(NSDictionary *d in _orderBookSell.array)
        {
            if([d[@"Volume"] doubleValue]>maxOrderValue)
                maxOrderValue=[d[@"Volume"] doubleValue];
            if([d[@"Volume"] doubleValue]<minOrderValue)
                minOrderValue=[d[@"Volume"] doubleValue];
            
        }


//        [self fillTopSubview];
        topScrollViewFilled=YES;
        
        for(UIView *v in _topScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        //        [self.view layoutIfNeeded];
        [self fillTopSubview];
        
        for(UIView *v in _bottomScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        
        [self fillBottomScrollView];

//        [self fillBottomScrollView];
        
//    }
//    
//    if(_orderBookBuy)
//    {
        CGFloat height=(35.0+1)*_orderBookBuy.array.count;
        if(_orderBookBuy.array.count==1)
            height=hhh;
        if(height<hhh)
        {
            _topScrollViewTopConstraint.constant=hhh-height;
            _topScrollViewHeight.constant=height;
        }
        else
        {
            [_topScrollView setContentOffset:CGPointMake(0, height-_topScrollView.bounds.size.height) animated:NO];
            origTopScrollOffset=height-_topScrollView.bounds.size.height;

        }
        [self.view layoutIfNeeded];
        
        _topScrollView.contentSize=CGSizeMake(_topScrollView.bounds.size.width, height);
        
        _bottomScrollView.contentSize=CGSizeMake(_bottomScrollView.bounds.size.width, (35.0+1)*_orderBookBuy.array.count);

        
//        [_topScrollView setContentOffset:CGPointMake(0, height-_topScrollView.bounds.size.height) animated:NO];
        //        [self.view setNeedsLayout];
        
        
//        [self.topScrollView setNeedsDisplay];
        [_topScrollView.layer removeAllAnimations];
        [_bottomScrollView.layer removeAllAnimations];
//        [self.view layoutIfNeeded];

    }

    
}

-(void) scrollTimerFired
{
    [_topScrollView.layer removeAllAnimations];

    CGFloat y=_topScrollView.contentOffset.y;
    
    NSLog(@"%f %f %f", y, _topScrollViewHeight.constant, velocity);
    
    y-=velocity/50;
    if(y<0)
    {
        y=0;
        [timer invalidate];
        NSLog(@"invalidate 1");
    }
    else if(y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height && _topScrollViewHeight.constant<=normalTopScrollViewHeight)
    {
        
        y=_topScrollView.contentSize.height-_topScrollView.bounds.size.height;
        [timer invalidate];
        NSLog(@"invalidate 2");

    }
    [_topScrollView setContentOffset:CGPointMake(0, y) animated:NO];
    NSLog(@"Timer y=%f", y);
    velocity=velocity-velocity/20;
    if(fabs(velocity)<10)
        [timer invalidate];
}

-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Began decelerating");
    [timer invalidate];
    CGPoint scrollVelocity = [[scrollView panGestureRecognizer] velocityInView:scrollView];
//    if(scrollVelocity.y>0)
//    {
        velocity=scrollVelocity.y;
        timer=[NSTimer timerWithTimeInterval:1.0/60 target:self selector:@selector(scrollTimerFired) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

//    }
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(flagStartedScroll==NO)
        return;
//    return;
    CGSize screenSize=[UIScreen mainScreen].bounds.size;

    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    CGPoint point=[self.view convertPoint:CGPointMake(0, 0) toView:window];
    point.y=point.y-20;
    
    CGFloat maxTopScrollViewHeight=[UIScreen mainScreen].bounds.size.height-point.y+13;
    normalTopScrollViewHeight=([UIScreen mainScreen].bounds.size.height-10-40-point.y-20)/2;
    
    CGFloat heightScrolled=origTopScrollOffset-_topScrollView.contentOffset.y;
    if(fabs(heightScrolled)<0.00001)
        return;
    if(fabs(heightScrolled)>100 && _topScrollViewHeight.constant==normalTopScrollViewHeight)
    {
        origTopScrollOffset=_topScrollView.contentOffset.y;
        return;
    }
    
    if(heightScrolled<0 && _topScrollViewHeight.constant==normalTopScrollViewHeight)
    {
        origTopScrollOffset=_topScrollView.contentOffset.y;
        return;
    }

    
    if(_topScrollView.contentOffset.y<0 || (_topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height && distToPopWindow==0 && _topScrollViewHeight.constant==normalTopScrollViewHeight))
    {
        origTopScrollOffset=_topScrollView.contentOffset.y;
        return;
    }
    
    if(heightScrolled>0 && _topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height)
    {
        origTopScrollOffset=_topScrollView.contentOffset.y;
        
        return;

    }
    
    if(prevMove==heightScrolled)
    {
        prevSameCount++;
        if(prevSameCount==2)
        {
            NSLog(@"BEGAN");
            origTopScrollOffset=_topScrollView.contentOffset.y;
            
            return;

        }
    }
    else
    {
        prevMove=heightScrolled;
        prevSameCount=0;
    }
    
    NSLog(@"%f", heightScrolled);
    
    if(distToPopWindow<point.y && heightScrolled>0)
    {
        
        distToPopWindow=distToPopWindow+heightScrolled;
        CGFloat delta=heightScrolled;

        if(distToPopWindow>point.y)
        {
            delta=distToPopWindow-point.y;
            distToPopWindow=point.y;
        }
        
        origTopScrollOffset-=delta*2;
//        delta=heightScrolled;
        
        _topScrollViewHeight.constant+=delta*2;
//        if(_topScrollViewHeight.constant>maxTopScrollViewHeight)
//        {
//            delta=_topScrollViewHeight.constant-maxTopScrollViewHeight;
//            _topScrollViewHeight.constant=maxTopScrollViewHeight;
//        }
        
        
        
        [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
        
        
    }
    else if(heightScrolled>0)
    {
        if(_topScrollViewHeight.constant==maxTopScrollViewHeight)
            origTopScrollOffset=_topScrollView.contentOffset.y;
        else
        {
            _topScrollViewHeight.constant+=heightScrolled;
            CGFloat delta=heightScrolled;
            if(_topScrollViewHeight.constant>maxTopScrollViewHeight)
            {
                delta=_topScrollViewHeight.constant-maxTopScrollViewHeight;
                _topScrollViewHeight.constant=maxTopScrollViewHeight;
            }
            
            origTopScrollOffset-=delta;
            [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
            
        }

    }
    else if(heightScrolled<0 && distToPopWindow>0 && _topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height)
    {
        distToPopWindow=distToPopWindow+heightScrolled;
        CGFloat delta=heightScrolled;
        if(distToPopWindow<0)
        {
            delta=heightScrolled-distToPopWindow;
//            origTopScrollOffset-=distToPopWindow;
            distToPopWindow=0;
        }
        CGFloat tomove=delta;
        
         origTopScrollOffset-=delta*2;
        
        
        _topScrollViewHeight.constant+=delta*2;
        if(_topScrollViewHeight.constant<normalTopScrollViewHeight)
        {
            delta=_topScrollViewHeight.constant-normalTopScrollViewHeight;
            _topScrollViewHeight.constant=normalTopScrollViewHeight;
        }

//        origTopScrollOffset-=delta;
        
        [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];


    }
    else if(heightScrolled<0 && distToPopWindow==0 && _topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height)
    {
        if(_topScrollViewHeight.constant==normalTopScrollViewHeight)
            origTopScrollOffset=_topScrollView.contentOffset.y;
        else
        {
            _topScrollViewHeight.constant+=heightScrolled;
            CGFloat delta=heightScrolled;
            if(_topScrollViewHeight.constant<normalTopScrollViewHeight)
            {
                delta=_topScrollViewHeight.constant-normalTopScrollViewHeight;
                _topScrollViewHeight.constant=normalTopScrollViewHeight;
            }

//            origTopScrollOffset-=delta;
            origTopScrollOffset=_topScrollView.contentSize.height-_topScrollViewHeight.constant;
            [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
            
        }

    }
    else
        origTopScrollOffset=_topScrollView.contentOffset.y;
    
//    distToPopWindow+=heightScrolled;
//    if(distToPopWindow<0)
//        distToPopWindow=0;
//    if(distToPopWindow>point.y)
//        distToPopWindow=point.y;
    
    
    CGRect rrr=[UIScreen mainScreen].bounds;
    rrr.origin.y=-distToPopWindow;
    
    rrr.size.height=[UIScreen mainScreen].bounds.size.height+distToPopWindow;
    window.frame=rrr;
    
    statusBarView.frame=CGRectMake(0, distToPopWindow, window.bounds.size.width, 20);

    
    return;
    
    
    
    
    
//    if(heightScrolled<0 && distToPopWindow==0)
//        return;
//    if(heightScrolled==0)
//        return;
//    distToPopWindow+=heightScrolled;
//    if(heightScrolled>point.y && NO)
//    {
////        return;
//        distToPopWindow=point.y;
//    }
//    else
//    {
//        CGFloat prev=_topScrollView.contentOffset.y;
//        NSLog(@"%d prev", (int)prev);
////        CGFloat next=
//        [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
//    }
//    
//    CGRect rrr=window.frame;
//    rrr.origin.y=-distToPopWindow;
//
//    rrr.size.height=[UIScreen mainScreen].bounds.size.height+distToPopWindow;
//    window.frame=rrr;
//    
//    statusBarView.frame=CGRectMake(0, distToPopWindow, window.bounds.size.width, 20);
//    
//    
//    CGFloat ccc=(screenSize.height-point.y-10)/2+heightScrolled;
//    if(ccc>screenSize.height-point.y)
//        ccc=screenSize.height-point.y;
    
//    NSLog(@"%d, %d, %d, %d", (int)heightScrolled, (int)distToPopWindow, (int)point.y, (int)ccc);
//
    _topScrollViewHeight.constant+=(heightScrolled*2);
    
}

//-(CGFloat) topScrollHeight
//{
//    CGSize screenSize=[UIScreen mainScreen].bounds.size;
//    
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
//    CGPoint point=[self.view convertPoint:CGPointMake(0, 0) toView:window];
//    
//    CGFloat heightScrolled=(_topScrollView.contentSize.height-_topScrollView.bounds.size.height)-_topScrollView.contentOffset.y;
//    if(heightScrolled<0)
//        return 0;
//    CGFloat distToPopWindow=heightScrolled;
//    if(heightScrolled>point.y)
//        distToPopWindow=point.y;
//    
//    CGFloat ccc=(screenSize.height-point.y-10)/2+heightScrolled;
//    if(ccc>screenSize.height-point.y)
//        ccc=screenSize.height-point.y;
//    
//    NSLog(@"%d, %d, %d, %d", (int)heightScrolled, (int)distToPopWindow, (int)point.y, (int)ccc);
//    
////    _topScrollViewHeight.constant=ccc;
//    return ccc;
//}

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

-(void) setOrderBookSell:(LWOrderBookElementModel *)orderBookSell
{
    _orderBookSell=orderBookSell;
    [self.view setNeedsLayout];
}

-(void) fillTopSubview
{
    CGFloat cellHeight=35;
    
    CGFloat height=(cellHeight+1)*_orderBookBuy.array.count;
    
    if(_orderBookBuy.array.count==1)
    {
        cellHeight=_topScrollView.bounds.size.height;
        height=cellHeight;
    }
    

    
    for(NSDictionary *d in _orderBookBuy.array)
    {
        LWOrderGraphView *view=[[LWOrderGraphView alloc] initWithPrice:[d[@"Price"] doubleValue] volume:[d[@"Volume"] doubleValue]];
        view.graphMaxVolume=maxOrderValue;
        view.graphMinVolume=minOrderValue;
        view.graphColor=[UIColor colorWithRed:1 green:247.0/255 blue:234.0/255 alpha:1];
        view.volumeColor=[UIColor colorWithRed:1 green:174.0/255 blue:44.0/255 alpha:1];
        view.assetPair=self.assetPair;
        view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        view.frame=CGRectMake(0, height-(cellHeight+1)*([_orderBookBuy.array indexOfObject:d]+1), _topScrollView.bounds.size.width, cellHeight);
        [_topScrollView addSubview:view];
        
    }
    _topScrollView.contentSize=CGSizeMake(_topScrollView.bounds.size.width, height);
//    _topScrollView.contentOffset=CGPointMake(0, height-_topScrollView.bounds.size.height);
}

-(void) fillBottomScrollView
{
    
    
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"Price" ascending:NO];
    NSArray *sortDescriptors=[NSArray arrayWithObject:descriptor];
    
    
    NSArray *array=[_orderBookSell.array sortedArrayUsingDescriptors:sortDescriptors];
    CGFloat cellHeight=35;

    CGFloat height=(cellHeight+1)*_orderBookSell.array.count;
    
    if(_orderBookSell.array.count==1)
    {
        cellHeight=_bottomScrollView.bounds.size.height;
        height=cellHeight;
    }

    
    
    
    for(NSDictionary *d in array)
    {
        LWOrderGraphView *view=[[LWOrderGraphView alloc] initWithPrice:[d[@"Price"] doubleValue] volume:[d[@"Volume"] doubleValue]];
        view.graphMaxVolume=maxOrderValue;
        view.graphMinVolume=minOrderValue;
        view.graphColor=[UIColor colorWithRed:246.0/255 green:229.0/255 blue:1 alpha:1];
        view.volumeColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
        view.assetPair=self.assetPair;
        view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        view.frame=CGRectMake(0, (cellHeight+1)*([array indexOfObject:d]), _bottomScrollView.bounds.size.width, cellHeight);
        [_bottomScrollView addSubview:view];
        
    }
    _bottomScrollView.contentSize=CGSizeMake(_bottomScrollView.bounds.size.width, height);

}

-(void) orientationChanged
{
    topScrollViewFilled=NO;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
