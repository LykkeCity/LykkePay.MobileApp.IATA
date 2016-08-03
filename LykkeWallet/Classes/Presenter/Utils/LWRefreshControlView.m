//
//  LWRefreshControlView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 31/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRefreshControlView.h"
#import "LWProgressView.h"

@interface LWRefreshControlView()
{
    LWProgressView *progress;
    UIView *backView;
}

@end

@implementation LWRefreshControlView

-(id) init
{
    self=[super init];
    self.tintColor=[UIColor clearColor];
    self.backgroundColor=[UIColor clearColor];
    
    
    self.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    progress=[[LWProgressView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [progress awakeFromNib];
    [progress startAnimating];
    [self addSubview:progress];
    
    
    
    
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    progress.center=CGPointMake(frame.size.width/2, frame.size.height/2);
    if(frame.size.height<30)
        progress.hidden=YES;
    else
        progress.hidden=NO;
    
    NSLog(@"%d    %d", (int)frame.origin.y, (int)frame.size.height);
    if(frame.origin.y==0)
        [progress stopAnimating];
    else
        [progress startAnimating];
}

//-(void) setRefreshControl:(UIRefreshControl *)refreshControl
//{
//    _refreshControl=refreshControl;
//    _refreshControl addTarget:self action:@selector(<#selector#>) forControlEvents:<#(UIControlEvents)#>
//}

@end
