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
    
    

}

@property CGFloat diameter;
@property (strong, nonatomic) UIView *squareBackground;

@property (strong, nonatomic) LWProgressView *sharedInstance;
@end


@implementation LWProgressView

-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    _squareBackground=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 110)];
    _squareBackground.backgroundColor=[UIColor whiteColor];
    _squareBackground.layer.cornerRadius=5;
    _squareBackground.alpha=0.9;
    UILabel *loading=[[UILabel alloc] initWithFrame:CGRectMake(0, 82, 120, 15)];
    
    NSDictionary *attributes=@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:11], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSKernAttributeName:@(1.1)};
    NSAttributedString *string=[[NSAttributedString alloc] initWithString:@"LOADING" attributes:attributes];
    loading.attributedText=string;
    loading.textAlignment=NSTextAlignmentCenter;
    
    [_squareBackground addSubview:loading];
    
    [self loadFrames];
    
    return self;
}

-(void) awakeFromNib
{
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
        sharedInstance.diameter=55;
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
    self.hidden=NO;
    [timer invalidate];
//    dispatch_async(dispatch_get_main_queue(), ^{
    timer=[NSTimer timerWithTimeInterval:0.017 target:self selector:@selector(repeatAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//        });
}

-(void) stopAnimating
{
    self.hidden=YES;
    [timer invalidate];
}


-(void) repeatAnimation
{
    [self setNeedsDisplay];
    count++;
    if(count==total)
    {
        count=0;
    }

}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    CGContextDrawImage(context, CGRectMake(self.bounds.size.width/2-_diameter/2, self.bounds.size.height/2-_diameter/2, _diameter, _diameter), images[count]);
}

-(void) removeFromSuperview
{
    [timer invalidate];
    [_squareBackground removeFromSuperview];
    [super removeFromSuperview];
}

-(void) dealloc
{
    [timer invalidate];
    for(int i=0;i<total;i++)
    {
        CGImageRelease(images[i]);
    }
}


@end
