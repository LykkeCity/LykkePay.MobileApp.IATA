//
//  LWAnimatedView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAnimatedView.h"

#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface LWAnimatedView()
{
    NSTimer *timer;
    FLAnimatedImageView *imageView;
    
    CGImageRef images[120];
    
    int total;
    int count;
}

@end

@implementation LWAnimatedView


-(id) initWithFrame:(CGRect)frame name:(NSString *) name
{
    self=[super initWithFrame:frame];
//    NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:gif_name ofType:@"gif"]];
//    FLAnimatedImage *image=[[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
//    
//    imageView=[[FLAnimatedImageView alloc] initWithFrame:self.bounds];
//    imageView.animatedImage=image;
//    [self addSubview:imageView];
//    [imageView startAnimating];
//
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
    total=0;
    for(int i=0;i<120; i++)
    {
        NSString *num=[NSString stringWithFormat:@"%d", i];
        while (num.length<5) {
            num=[@"0" stringByAppendingString:num];
        }
        NSString *filename=[NSString stringWithFormat:@"%@_%@.png", name,num];
        NSString *path=[[NSBundle mainBundle] pathForResource:filename ofType:nil];
        if(!path)
            break;
        NSData *data=[NSData dataWithContentsOfFile:path];
         total++;
        CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
        CGImageRef image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault); // Or JPEGDataProvider
        images[i]=image;
    }
    });

    
    count=0;
    
    return self;
}

-(void) startAnimationIfNeeded
{
    timer=[NSTimer timerWithTimeInterval:0.017 target:self selector:@selector(repeatAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}


-(void) repeatAnimation
{
    [self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, self.bounds, images[count]);
    count++;
    if(count==total)
    {
        [timer invalidate];
        count=total-1;
    }
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
