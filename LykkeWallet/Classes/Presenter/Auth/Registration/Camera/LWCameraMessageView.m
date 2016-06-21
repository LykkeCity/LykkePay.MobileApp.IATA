//
//  LWCameraMessageView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCameraMessageView.h"

@interface LWCameraMessageView()

@property (weak, nonatomic) IBOutlet UILabel *cameraDisconnectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lykkeLabel;
@property (weak, nonatomic) IBOutlet UILabel *setCameraLabel;


@end

@implementation LWCameraMessageView

-(void) awakeFromNib
{
    self.alpha=0;
    self.cameraDisconnectedLabel.textColor=[UIColor colorWithRed:31.0/255 green:149.0/255 blue:1 alpha:1];
    UIColor *textColor=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
    self.textLabel.textColor=textColor;
    self.settingsLabel.textColor=textColor;
    self.lykkeLabel.textColor=textColor;
    self.setCameraLabel.textColor=textColor;
}


-(void) show
{
    self.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.5];
    self.opaque=NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=1;
    }];

}


-(IBAction) understandPressed:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished){
        
        [self removeFromSuperview];
    }];
    
}
@end
