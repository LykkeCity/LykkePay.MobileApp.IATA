//
//  LWKYCLaterMessageView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCLaterMessageView.h"

@interface LWKYCLaterMessageView()
{
    UIWindow *window;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation LWKYCLaterMessageView

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.alpha=0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _widthConstraint.constant=280;
    
    _titleLabel.textColor=[UIColor colorWithRed:31.0/255 green:149.0/255 blue:1 alpha:1];

}

-(void) show
{
    CGRect frame;
//    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        frame=[UIScreen mainScreen].bounds;
//    else
//        frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    window = [[UIWindow alloc] initWithFrame:frame];
    window.backgroundColor = nil;
    window.windowLevel = UIWindowLevelNormal;
//    window.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window addSubview:self];
    self.frame=window.bounds;
    self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window makeKeyAndVisible];
    
    self.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    self.opaque=NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=1;
    }];

}



-(IBAction)greatPressed:(id)sender
{
    [self hide];
}


-(void) hide
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished){
        
        [self removeFromSuperview];
        window=nil;
        [self.delegate laterMessageViewDismissed];
    }];
    
}

-(void) orientationChanged
{
    window.frame=[UIScreen mainScreen].bounds;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
