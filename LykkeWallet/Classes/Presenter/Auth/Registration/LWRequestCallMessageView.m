//
//  LWRequestCallMessageView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRequestCallMessageView.h"

@interface LWRequestCallMessageView()
{
    void (^completionBlock)(void);
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidth;


@end

@implementation LWRequestCallMessageView

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.alpha=0;
    self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textColor=[UIColor colorWithRed:31.0/255 green:149.0/255 blue:1 alpha:1];
    UIColor *textColor=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
    self.textLabel.textColor=textColor;
    
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        _viewWidth.constant=280;
    }
}


-(void) showWithCompletion:(void(^)(void)) completion
{
    completionBlock=completion;
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
        if(completionBlock)
            completionBlock();
    }];
    
}
@end
