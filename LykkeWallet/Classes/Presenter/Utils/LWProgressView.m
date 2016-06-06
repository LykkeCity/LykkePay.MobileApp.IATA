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

@property (strong, nonatomic) LWProgressView *sharedInstance;
@end


@implementation LWProgressView

+ (instancetype)sharedInstance
{
    static LWProgressView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LWProgressView alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+(void) showInView:(UIView *) view
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [[LWProgressView sharedInstance] removeFromSuperview];
    [view addSubview:[LWProgressView sharedInstance]];
    [LWProgressView sharedInstance].center=CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    [[LWProgressView sharedInstance] startAnimation];
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
    self=[super initWithFrame:CGRectMake(0, 0, 1024, 1024)];
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
    
    
    
    count=0;
    
    return self;
}



-(void) startAnimation
{
//    dispatch_async(dispatch_get_main_queue(), ^{
    timer=[NSTimer timerWithTimeInterval:0.017 target:self selector:@selector(repeatAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//        });
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
    
    CGContextDrawImage(context, CGRectMake(self.bounds.size.width/2-55.0/2, self.bounds.size.height/2-55.0/2, 55, 55), images[count]);
}

-(void) removeFromSuperview
{
    [timer invalidate];
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
