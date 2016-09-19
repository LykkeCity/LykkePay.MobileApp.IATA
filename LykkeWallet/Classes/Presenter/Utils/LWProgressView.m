//
//  LWProgressView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 06/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWProgressView.h"

@interface LWProgressView()
{
    NSTimer *timer;
    
    CGImageRef images[120];
    
    int total;
    int count;
    
    BOOL isAnimating;
    
    int loopCount;

}

@property CGFloat diameter;
@property (strong, nonatomic) UIVisualEffectView *squareBackground;

@property (strong, nonatomic) LWProgressView *sharedInstance;
@end


@implementation LWProgressView

-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    isAnimating=NO;
    loopCount=0;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _squareBackground = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
//    _squareBackground=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _squareBackground.frame=CGRectMake(0, 0, 90, 90);
    _squareBackground.backgroundColor=[UIColor whiteColor];
    _squareBackground.layer.cornerRadius=5;
    _squareBackground.alpha=0.7;
//    UILabel *loading=[[UILabel alloc] initWithFrame:CGRectMake(0, 82, 120, 15)];
//    
//    NSDictionary *attributes=@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:11], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSKernAttributeName:@(1.1)};
//    NSAttributedString *string=[[NSAttributedString alloc] initWithString:@"LOADING" attributes:attributes];
//    loading.attributedText=string;
//    loading.textAlignment=NSTextAlignmentCenter;
    
//    [_squareBackground addSubview:loading];
    
    [self loadFrames];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    

    
    return self;
}

-(void) orientationChanged
{
    
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    CGPoint point=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);
    CGPoint myCenter=[window convertPoint:point toView:self.superview];
    
    self.center=myCenter;
    _squareBackground.center=myCenter;

}

-(void) awakeFromNib
{
    isAnimating=NO;
    loopCount=0;
    [self loadFrames];
    self.diameter=self.bounds.size.width;
    if(self.diameter>30)
        self.diameter=30;
    
}


+ (instancetype)sharedInstance
{
    static LWProgressView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[LWProgressView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        sharedInstance.diameter=50;
    });
    return sharedInstance;
}

+(void) showInView:(UIView *) view
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [[LWProgressView sharedInstance] removeFromSuperview];
        
        [view addSubview:[LWProgressView sharedInstance].squareBackground];
    
    [view addSubview:[LWProgressView sharedInstance]];
    [LWProgressView sharedInstance].center=CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        
        [LWProgressView sharedInstance].squareBackground.center=CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        
    [[LWProgressView sharedInstance] startAnimating];
        });
}

+(void) hide
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [[LWProgressView sharedInstance] removeFromSuperview];
    });
}

-(id) init
{
    self=[super initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.diameter=30;
    loopCount=0;
    [self loadFrames];
    return self;
}

-(void) loadFrames
{
    self.backgroundColor=nil;
    self.opaque=NO;
    total=0;
    for(int i=0;i<=80; i++)
    {
        NSString *num=[NSString stringWithFormat:@"%d", i];
        while (num.length<5) {
            num=[@"0" stringByAppendingString:num];
        }
        NSString *filename=[NSString stringWithFormat:@"loader-color@2x_%@.png", num];
        NSString *path=[[NSBundle mainBundle] pathForResource:filename ofType:nil];
        if(!path)
            break;
        NSData *data=[NSData dataWithContentsOfFile:path];
        total++;
        CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
        CGImageRef image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault); // Or JPEGDataProvider
        images[i]=image;
    }
    
    self.hidden=YES;
    self.clipsToBounds=NO;
    
    count=0;
 
}


-(void) startAnimating
{
    if(isAnimating)
        return;
    self.hidden=NO;
    [timer invalidate];
//    dispatch_async(dispatch_get_main_queue(), ^{
//    timer=[NSTimer timerWithTimeInterval:0.017 target:self selector:@selector(repeatAnimation) userInfo:nil repeats:YES];
    
    isAnimating=YES;
    
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
//        });
    
    [self performSelectorInBackground:@selector(startLoop) withObject:nil];
}

-(void) startLoop
{
    NSLog(@"Started loop");
    loopCount++;
    while(isAnimating)
    {
        if(loopCount>1)
            break;
    [NSThread sleepForTimeInterval:0.005];
    [self repeatAnimation];
        if(isAnimating==NO)
            break;
    }
    loopCount--;
}

-(void) stopAnimating
{
    isAnimating=NO;
    self.hidden=YES;
    [timer invalidate];
}


-(void) repeatAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self setNeedsDisplay];
        });
    count++;
    if(count==total)
    {
        count=0;
    }
    
//    NSLog(@"TIMER CALLED %d", count);

}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    CGContextDrawImage(context, CGRectMake(self.bounds.size.width/2-_diameter/2, self.bounds.size.height/2-_diameter/2, _diameter, _diameter), images[count]);
    
//    UIView *vvv=self.superview;
//    UIView *vvv1=self.superview.superview;
//    UIView *vvv2=self.superview.superview.superview;
//
//    NSLog(@"CALLED DRAWRECT");
    
 }

-(void) removeFromSuperview
{
    [timer invalidate];
    isAnimating=NO;
    [_squareBackground removeFromSuperview];
    [super removeFromSuperview];
}

-(void) dealloc
{
    isAnimating=NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timer invalidate];
    for(int i=0;i<total;i++)
    {
        CGImageRelease(images[i]);
    }
}


@end





