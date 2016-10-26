//
//  LWCameraMessageView2.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCameraMessageView2.h"

@interface LWCameraMessageView2()
{
    void (^completionBlock)(BOOL);
}

@property (weak, nonatomic) IBOutlet UILabel *cameraDisconnectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;


@end

@implementation LWCameraMessageView2

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.alpha=0;
    self.cameraDisconnectedLabel.textColor=[UIColor colorWithRed:31.0/255 green:149.0/255 blue:1 alpha:1];
    UIColor *textColor=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
    self.textLabel.textColor=textColor;
    [self checkLinesInView:self];
}

-(void) checkLinesInView:(UIView *) view
{
    for(UIView *v in view.subviews)
    {
        if([v isKindOfClass:[UIView class]])
        {
            for(NSLayoutConstraint *c in v.constraints)
            {
                if(c.firstAttribute==NSLayoutAttributeWidth && c.constant==1)
                    c.constant=0.5;
                if(c.firstAttribute==NSLayoutAttributeHeight && c.constant==1)
                    c.constant=0.5;
            }
            
        }
        [self checkLinesInView:v];
        
    }
}


-(void) showWithCompletion:(void(^)(BOOL result)) completion
{
    completionBlock=completion;
    self.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    self.opaque=NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=1;
    }];

}

-(IBAction)yesPressed:(id)sender
{
    [self hide:YES];
}

-(IBAction)noPressed:(id)sender
{
    [self hide:NO];
}

-(void) hide:(BOOL) result
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished){
        
        [self removeFromSuperview];
        completionBlock(result);
    }];
    
}
@end
