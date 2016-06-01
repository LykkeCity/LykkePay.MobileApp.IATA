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
}

@end

@implementation LWAnimatedView


-(id) initWithFrame:(CGRect)frame gifName:(NSString *) gif_name
{
    self=[super initWithFrame:frame];
    NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:gif_name ofType:@"gif"]];
    FLAnimatedImage *image=[[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    
    imageView=[[FLAnimatedImageView alloc] initWithFrame:self.bounds];
    imageView.animatedImage=image;
    [self addSubview:imageView];
    [imageView startAnimating];
    
    timer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(repeatAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    return self;
}

-(void) repeatAnimation
{
//    [imageView startAnimating];
}

-(void) dealloc
{
    [timer invalidate];
}

@end
