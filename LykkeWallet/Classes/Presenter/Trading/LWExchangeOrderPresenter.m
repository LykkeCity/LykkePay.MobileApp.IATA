//
//  LWExchangeOrderPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWExchangeOrderPresenter.h"
#import "LWOrderGraphView.h"

#define ONE_LINE_HEIGHT 35.0

@interface LWExchangeOrderPresenter () <UIScrollViewDelegate>
{
    BOOL topScrollViewFilled;
    double maxOrderValue;
    double minOrderValue;
    
    UIView *statusBarView;
    CGFloat distToPopWindow;
    
    CGFloat origTopScrollOffset;
    CGFloat origBottomScrollOffset;
    
    NSTimer *timer;
    
    float velocity;
    CGFloat normalTopScrollViewHeight;
    
    float prevMove;
    int prevSameCount;
    
    BOOL flagStartedScroll;
    BOOL flagScrollingTop;
    BOOL flagReturningToCenter;
    
    BOOL flagScrollIsWorkingNow;
    int flagHeaderDirectionShowing;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScrollViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScrollViewTopConstraint;

@end

@implementation LWExchangeOrderPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.multipleTouchEnabled=NO;
    _topScrollView.multipleTouchEnabled=NO;
    _bottomScrollView.multipleTouchEnabled=NO;
    [self adjustThinLines];
    prevSameCount=0;
    
    flagScrollIsWorkingNow=NO;
    
    _topScrollView.delegate=self;
    _bottomScrollView.delegate=self;
    
    _topScrollView.layer.shouldRasterize=YES;
    _topScrollView.layer.rasterizationScale= [UIScreen mainScreen].scale;
    
    _bottomScrollView.layer.shouldRasterize=YES;
    _bottomScrollView.layer.rasterizationScale=[UIScreen mainScreen].scale;
    
    topScrollViewFilled=NO;
    
    flagReturningToCenter=NO;
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [_topScrollView addGestureRecognizer:gesture];
    
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [_bottomScrollView addGestureRecognizer:gesture];
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    flagStartedScroll=NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    distToPopWindow=0;

    flagScrollingTop=NO;
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        UIWindow *window=self.view.window;
        if(statusBarView)
            [statusBarView removeFromSuperview];
        statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.bounds.size.width, 20)];
        statusBarView.backgroundColor=[UIColor whiteColor];
        [window addSubview:statusBarView];
        
    }
    

}

-(void) scrollViewTapped:(UITapGestureRecognizer *) gesture
{
    if((gesture.view==_topScrollView && _topScrollView.bounds.size.height<ONE_LINE_HEIGHT+2) || (gesture.view==_bottomScrollView && _bottomScrollView.bounds.size.height<ONE_LINE_HEIGHT+2))
    {
        [timer invalidate];
        flagReturningToCenter=YES;
        [self.view layoutIfNeeded];
        
        UIWindow *window=self.view.window;
 
        
        
        _topScrollViewHeight.constant=normalTopScrollViewHeight;
        
        [UIView animateWithDuration:0.5 animations:^{
            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
            {
                window.frame=[UIScreen mainScreen].bounds;
                statusBarView.frame=CGRectMake(0, 0, window.bounds.size.width, 20);
            }
            _topScrollView.contentOffset=CGPointMake(0, _topScrollView.contentSize.height-normalTopScrollViewHeight);
            _bottomScrollView.contentOffset=CGPointMake(0, 0);
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished){
            distToPopWindow=0;
            flagReturningToCenter=NO;
        }];
        
    }

}


-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView==_topScrollView)
        _bottomScrollView.userInteractionEnabled=NO;
    else
        _topScrollView.userInteractionEnabled=NO;
    [timer invalidate];

    [_topScrollView.layer removeAllAnimations];
    [_bottomScrollView.layer removeAllAnimations];
    
    
    

//    [self.view layoutIfNeeded];
    flagStartedScroll=YES;

    flagScrollingTop=(scrollView==_topScrollView);
    
}


-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    scrollView.scrollEnabled = NO;
//    scrollView.scrollEnabled = YES;

    _topScrollView.userInteractionEnabled=YES;
    _bottomScrollView.userInteractionEnabled=YES;
    
    if(decelerate==NO)
    {
        [self showHideHeaderIfNeeded];
    }
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



        topScrollViewFilled=YES;
        
        for(UIView *v in _topScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        
        [self fillTopSubview];
        
        for(UIView *v in _bottomScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        
        [self fillBottomScrollView];
        CGFloat height=(ONE_LINE_HEIGHT+1)*_orderBookBuy.array.count;
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
        
        _bottomScrollView.contentSize=CGSizeMake(_bottomScrollView.bounds.size.width, (ONE_LINE_HEIGHT+1)*_orderBookBuy.array.count);
        [_topScrollView.layer removeAllAnimations];
        [_bottomScrollView.layer removeAllAnimations];
//        [self.view layoutIfNeeded];

    }

    
}

-(void) scrollTimerFired
{
    [_topScrollView.layer removeAllAnimations];
    [_bottomScrollView.layer removeAllAnimations];

    if(flagScrollingTop)
    {
        CGFloat y=_topScrollView.contentOffset.y;
        
        NSLog(@"%f %f %f", y, _topScrollViewHeight.constant, velocity);
        
        y+=velocity/50;
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
        if(fabs(velocity)<100)
            [timer invalidate];
    }
    else
    {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        CGPoint point=[self.view convertPoint:CGPointMake(0, 0) toView:window];
        point.y=point.y-20;

        CGFloat y=_bottomScrollView.contentOffset.y;
        
//        NSLog(@"%f %f %f", y, _topScrollViewHeight.constant, velocity);
        
        y+=velocity/50;
        if(y>_bottomScrollView.contentSize.height-_bottomScrollView.bounds.size.height && (distToPopWindow==point.y || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) && _topScrollViewHeight.constant==ONE_LINE_HEIGHT)
        {
            y=_bottomScrollView.contentSize.height-_bottomScrollView.bounds.size.height;
            [timer invalidate];
            NSLog(@"invalidate2 1");
        }
        else if((y<0 || _bottomScrollView.contentOffset.y<0) && (distToPopWindow==0 || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) && _topScrollViewHeight.constant==normalTopScrollViewHeight)
        {
            
            y=0;
            [timer invalidate];
            NSLog(@"invalidate2 2");
            
        }
        [_bottomScrollView setContentOffset:CGPointMake(0, y) animated:NO];
        NSLog(@"Timer2 y=%f", y);
        velocity=velocity-velocity/20;
        if(fabs(velocity)<100)
            [timer invalidate];
    }
    
    if(timer.isValid==NO)
        [self showHideHeaderIfNeeded];

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)scrollVelocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    if(scrollView==_bottomScrollView)
//        return;
    NSLog(@"Began decelerating");
    CGFloat fff=scrollView.contentOffset.y;
//    if(scrollView.contentOffset.y<0)
//    {
//        [scrollView.layer removeAllAnimations];
//        
//        scrollView.scrollEnabled = NO;
//        scrollView.scrollEnabled = YES;
//
//        return;
//    }

    [scrollView.layer removeAllAnimations];
    
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
    
    [timer invalidate];
        velocity=scrollVelocity.y*300;
        timer=[NSTimer timerWithTimeInterval:1.0/60 target:self selector:@selector(scrollTimerFired) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(flagStartedScroll==NO || flagReturningToCenter || flagScrollIsWorkingNow)
        return;

    CGFloat prevDistToPopWindow=distToPopWindow;
    flagScrollIsWorkingNow=YES;
    if(scrollView==_bottomScrollView && flagScrollingTop==NO)
    {
        [self bottomScrollViewScrolled];
        
        float ddd=_topScrollView.contentOffset.y/(ONE_LINE_HEIGHT+1);
        

        if(_topScrollView.contentOffset.y>0 && ddd!=(int)ddd && _topScrollViewHeight.constant<=ONE_LINE_HEIGHT)
        {
            if(_topScrollView.contentSize.height>(int)(ddd+1)*(ONE_LINE_HEIGHT+1))
                ddd+=1;
            origTopScrollOffset=(int)ddd*(ONE_LINE_HEIGHT+1);
            [_topScrollView setContentOffset:CGPointMake(0, origTopScrollOffset) animated:NO];
        }
        flagScrollIsWorkingNow=NO;
    }
    else
    {
        [self topScrollViewScrolled];
        
        float ddd=_bottomScrollView.contentOffset.y/(ONE_LINE_HEIGHT+1);
        if(_bottomScrollView.contentOffset.y>0 && ddd!=(int)ddd)
        {
            origBottomScrollOffset=(int)ddd*(ONE_LINE_HEIGHT+1);
            [_bottomScrollView setContentOffset:CGPointMake(0, origBottomScrollOffset) animated:NO];
        }

        flagScrollIsWorkingNow=NO;
    }
    if(prevDistToPopWindow==distToPopWindow)
        flagHeaderDirectionShowing=0;
    else if(prevDistToPopWindow>distToPopWindow)
        flagHeaderDirectionShowing=1;
    else
        flagHeaderDirectionShowing=-1;
        
//    flagHeaderDirectionShowing=prevDistToPopWindow>distToPopWindow;
    
    NSLog(@"Showing header %d", (int)flagHeaderDirectionShowing);
    
//    [self.view layoutIfNeeded];
    
    
    
}

-(void) topScrollViewScrolled
{
    
    if(flagScrollingTop==NO)
    {
        origTopScrollOffset=_topScrollView.contentOffset.y;
        return;
    }
    
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    CGPoint point=[self.view convertPoint:CGPointMake(0, 0) toView:window];
    point.y=point.y-20;
    
    CGFloat maxTopScrollViewHeight=[UIScreen mainScreen].bounds.size.height-point.y+13-ONE_LINE_HEIGHT;
    normalTopScrollViewHeight=([UIScreen mainScreen].bounds.size.height-10-40-point.y-20)/2;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        maxTopScrollViewHeight=self.view.bounds.size.height-40-10-ONE_LINE_HEIGHT;
        normalTopScrollViewHeight=(self.view.bounds.size.height-40-10)/2;
    }
    
    CGFloat heightScrolled=origTopScrollOffset-_topScrollView.contentOffset.y;
    
    CGRect a=_topScrollView.frame;
    CGSize b=_topScrollView.contentSize;
    CGPoint c=_topScrollView.contentOffset;
    
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

    
    if(_topScrollView.contentOffset.y<0 || (_topScrollView.contentOffset.y>=_topScrollView.contentSize.height-_topScrollView.bounds.size.height && (distToPopWindow==0 || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) && _topScrollViewHeight.constant==normalTopScrollViewHeight))
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
            prevSameCount--;
//            origTopScrollOffset=_topScrollView.contentOffset.y;
//            
//            return;

        }
    }
    else
    {
        prevMove=heightScrolled;
        prevSameCount=0;
    }
    
    NSLog(@"%f", heightScrolled);
    
    if(distToPopWindow<point.y && heightScrolled>0 && [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        
        distToPopWindow=distToPopWindow+heightScrolled;
        CGFloat delta=heightScrolled;

        if(distToPopWindow>point.y)
        {
            delta=distToPopWindow-point.y;
            distToPopWindow=point.y;
        }
        
        origTopScrollOffset-=delta*2;
        
        _topScrollViewHeight.constant+=delta*2;
        
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
    else if(heightScrolled<0 && distToPopWindow>0 && _topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height && [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        distToPopWindow=distToPopWindow+heightScrolled;
        CGFloat delta=heightScrolled;
        if(distToPopWindow<0)
        {
            delta=heightScrolled-distToPopWindow;

            distToPopWindow=0;
        }
        
         origTopScrollOffset-=delta*2;
        
        
        _topScrollViewHeight.constant+=delta*2;
        if(_topScrollViewHeight.constant<normalTopScrollViewHeight)
        {
            delta=_topScrollViewHeight.constant-normalTopScrollViewHeight;
            _topScrollViewHeight.constant=normalTopScrollViewHeight;
        }
        
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

            origTopScrollOffset=_topScrollView.contentSize.height-_topScrollViewHeight.constant;
            [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
            
        }

    }
    else
        origTopScrollOffset=_topScrollView.contentOffset.y;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        CGRect rrr=[UIScreen mainScreen].bounds;
        rrr.origin.y=-distToPopWindow;
        
        rrr.size.height=[UIScreen mainScreen].bounds.size.height+distToPopWindow;
        window.frame=rrr;
        
        statusBarView.frame=CGRectMake(0, distToPopWindow, window.bounds.size.width, 20);
    }
    
}

//BOTTOM SCROLL VIEW
-(void) bottomScrollViewScrolled
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    CGPoint point=[self.view convertPoint:CGPointMake(0, 0) toView:window];
    point.y=point.y-20;
    
    CGFloat maxTopScrollViewHeight=[UIScreen mainScreen].bounds.size.height-point.y+13-ONE_LINE_HEIGHT;
    normalTopScrollViewHeight=([UIScreen mainScreen].bounds.size.height-10-40-point.y-20)/2;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        maxTopScrollViewHeight=self.view.bounds.size.height-40-10-ONE_LINE_HEIGHT;
        normalTopScrollViewHeight=(self.view.bounds.size.height-40-10)/2;
    }
    
    CGFloat heightScrolled=origBottomScrollOffset-_bottomScrollView.contentOffset.y;
    CGFloat tttttt=_bottomScrollView.contentOffset.y;
    
    if(fabs(heightScrolled)<0.001)
        return;
    if(fabs(heightScrolled)>100 && _topScrollViewHeight.constant==normalTopScrollViewHeight)
    {
        origBottomScrollOffset=_bottomScrollView.contentOffset.y;
        return;
    }
    
    if(heightScrolled<0 && _topScrollViewHeight.constant==ONE_LINE_HEIGHT && (distToPopWindow==point.y || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad))
    {
        origBottomScrollOffset=_bottomScrollView.contentOffset.y;
        return;
    }
    
//    if(heightScrolled<0 && origBottomScrollOffset<0)
//    {
//        heightScrolled=-origBottomScrollOffset;
////        return;
//    }
//
    
    if((_bottomScrollView.contentOffset.y<0 || origBottomScrollOffset<0) && _topScrollViewHeight.constant==normalTopScrollViewHeight && (distToPopWindow==0 || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) )
    {
        origBottomScrollOffset=_bottomScrollView.contentOffset.y;
        return;
    }
    
//    if([timer isValid] && velocity<0 && _bottomScrollView.contentOffset.y<0)
//    {
//        origBottomScrollOffset=_bottomScrollView.contentOffset.y;
//        return;
//    }
  

    
    
//    if(_bottomScrollView.contentOffset.y<0 || (_topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height && (distToPopWindow==0 || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) && _topScrollViewHeight.constant==normalTopScrollViewHeight))
//    {
//        origTopScrollOffset=_topScrollView.contentOffset.y;
//        return;
//    }
//    
//    if(heightScrolled>0 && _topScrollView.contentOffset.y>_topScrollView.contentSize.height-_topScrollView.bounds.size.height)
//    {
//        origTopScrollOffset=_topScrollView.contentOffset.y;
//        
//        return;
//        
//    }
    
    if(prevMove==heightScrolled)
    {
        prevSameCount++;
        if(prevSameCount==2)
        {
            NSLog(@"BEGAN");
//            [timer invalidate];
//            origBottomScrollOffset=_bottomScrollView.contentOffset.y;
            prevSameCount--;
//            return;
            
        }
    }
    else
    {
        prevMove=heightScrolled;
        prevSameCount=0;
    }
    
    NSLog(@"%f", heightScrolled);
    
    if(distToPopWindow<point.y && heightScrolled<0 && [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        
        distToPopWindow=distToPopWindow-heightScrolled;
        CGFloat delta=heightScrolled;
        
        if(distToPopWindow>point.y)
        {
            delta=distToPopWindow-point.y;
            distToPopWindow=point.y;
        }
        
//        origTopScrollOffset-=delta;
        
//        _topScrollViewHeight.constant+=delta*2;
        
//        [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
        [_bottomScrollView setContentOffset:CGPointMake(_bottomScrollView.contentOffset.x, origBottomScrollOffset) animated:NO];
        
        
    }
    else if(heightScrolled<0)
    {
        if(_topScrollViewHeight.constant==ONE_LINE_HEIGHT)
            origBottomScrollOffset=_bottomScrollView.contentOffset.y;
        else
        {
            _topScrollViewHeight.constant+=heightScrolled;
            CGFloat delta=heightScrolled;
            if(_topScrollViewHeight.constant<ONE_LINE_HEIGHT)
            {
//                delta=-_topScrollViewHeight.constant;
                delta=heightScrolled+(ONE_LINE_HEIGHT-_topScrollViewHeight.constant);
                _topScrollViewHeight.constant=ONE_LINE_HEIGHT;
            }
            
//            origTopScrollOffset-=delta*2;
            origTopScrollOffset-=delta;
            [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
            [_bottomScrollView setContentOffset:CGPointMake(_bottomScrollView.contentOffset.x, origBottomScrollOffset) animated:NO];

        }
        
    }
    else if(heightScrolled>0 && distToPopWindow>0 && _bottomScrollView.contentOffset.y<0 && [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        distToPopWindow=distToPopWindow-heightScrolled;
        CGFloat delta=heightScrolled;
        if(distToPopWindow<0)
        {
            delta=heightScrolled-distToPopWindow;
            
            distToPopWindow=0;
        }
        
//        origTopScrollOffset-=delta*2;
        
        
//        _topScrollViewHeight.constant+=delta*2;
//        if(_topScrollViewHeight.constant>normalTopScrollViewHeight)
//        {
//            delta=_topScrollViewHeight.constant-normalTopScrollViewHeight;
//            _topScrollViewHeight.constant=normalTopScrollViewHeight;
//        }
        
//        [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
        [_bottomScrollView setContentOffset:CGPointMake(_bottomScrollView.contentOffset.x, 0)];
        
    }
    else if(heightScrolled>0 && (distToPopWindow==0 || [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) && _bottomScrollView.contentOffset.y<0)
    {
        if(_topScrollViewHeight.constant==normalTopScrollViewHeight)
            origBottomScrollOffset=_bottomScrollView.contentOffset.y;
        else
        {
            _topScrollViewHeight.constant+=heightScrolled;
            CGFloat delta=heightScrolled;
            if(_topScrollViewHeight.constant>normalTopScrollViewHeight)
            {
                delta=heightScrolled-(_topScrollViewHeight.constant-normalTopScrollViewHeight);
                _topScrollViewHeight.constant=normalTopScrollViewHeight;
            }
            
            origTopScrollOffset-=delta;
            [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x, origTopScrollOffset ) animated:NO];
            [_bottomScrollView setContentOffset:CGPointMake(_bottomScrollView.contentOffset.x, 0)];

        }
        
    }
    else
        origBottomScrollOffset=_bottomScrollView.contentOffset.y;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        CGRect rrr=[UIScreen mainScreen].bounds;
        rrr.origin.y=-distToPopWindow;
        
        rrr.size.height=[UIScreen mainScreen].bounds.size.height+distToPopWindow;
        window.frame=rrr;
        
        statusBarView.frame=CGRectMake(0, distToPopWindow, window.bounds.size.width, 20);
    }
    
}



-(void) setOrderBookSell:(LWOrderBookElementModel *)orderBookSell
{
    _orderBookSell=orderBookSell;
    [self.view setNeedsLayout];
}

-(void) fillTopSubview
{
    CGFloat cellHeight=ONE_LINE_HEIGHT;
    
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

}

-(void) fillBottomScrollView
{
    
    
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"Price" ascending:NO];
    NSArray *sortDescriptors=[NSArray arrayWithObject:descriptor];
    
    
    NSArray *array=[_orderBookSell.array sortedArrayUsingDescriptors:sortDescriptors];
    CGFloat cellHeight=ONE_LINE_HEIGHT;

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

-(void) showHideHeaderIfNeeded
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        return;
    UIWindow *window=self.view.window;
    CGPoint point=[self.view convertPoint:CGPointMake(0, 0) toView:window];
    point.y=point.y-20;
    
    if((flagHeaderDirectionShowing==1 && distToPopWindow>0) || (flagHeaderDirectionShowing==0 && distToPopWindow>0 && distToPopWindow<point.y))
    {
        self.view.userInteractionEnabled=NO;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rrr=[UIScreen mainScreen].bounds;
            distToPopWindow=0;
            rrr.origin.y=distToPopWindow;
            rrr.size.height=[UIScreen mainScreen].bounds.size.height+distToPopWindow;
            window.frame=rrr;
            statusBarView.frame=CGRectMake(0, distToPopWindow, window.bounds.size.width, 20);
        } completion:^(BOOL finished){
            if(_bottomScrollView.bounds.size.height<ONE_LINE_HEIGHT)
            {
                [self.view layoutIfNeeded];
                _topScrollViewHeight.constant=self.view.bounds.size.height-44-10-ONE_LINE_HEIGHT;
                [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                } completion:^(BOOL finished){
                    self.view.userInteractionEnabled=YES;

                }];
            }
            else
                self.view.userInteractionEnabled=YES;
        }
         ];

    }
    else if(flagHeaderDirectionShowing==-1 && distToPopWindow<point.y)
    {
        self.view.userInteractionEnabled=NO;

        [UIView animateWithDuration:0.3 animations:^{
            CGRect rrr=[UIScreen mainScreen].bounds;
            distToPopWindow=point.y;
            rrr.origin.y=-distToPopWindow;
            rrr.size.height=[UIScreen mainScreen].bounds.size.height+distToPopWindow;
            window.frame=rrr;
            statusBarView.frame=CGRectMake(0, distToPopWindow, window.bounds.size.width, 20);
        } completion:^(BOOL finished){
            self.view.userInteractionEnabled=YES;
        }];

    }

}

-(void) orientationChanged
{
    [timer invalidate];
    topScrollViewFilled=NO;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timer invalidate];
}

@end
