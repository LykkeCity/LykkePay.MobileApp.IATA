//
//  LWMathKeyboardCursorView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMathKeyboardCursorView.h"

@interface LWMathKeyboardCursorView()
{
    UIImageView *image;
    NSTimer *timer;
    
    BOOL flagVisible;
}

@end

@implementation LWMathKeyboardCursorView

-(id) init
{
    self=[super initWithFrame:CGRectMake(0, 0, 3, 25)];
    flagVisible=YES;
    image=[[UIImageView alloc] initWithFrame:self.bounds];
    image.image=[UIImage imageNamed:@"CustomKeyboardPointer.png"];
    [self addSubview:image];
    
    timer=[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    return self;

}

-(void) timerFired
{
    flagVisible=!flagVisible;
    image.hidden=flagVisible;
}

-(void) removeFromSuperview
{
    [super removeFromSuperview];
    [timer invalidate];
}

-(void) dealloc
{
    [timer invalidate];
}





@end
