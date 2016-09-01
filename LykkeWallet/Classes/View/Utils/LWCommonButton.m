//
//  LWCommonButton.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCommonButton.h"

@interface LWCommonButton()
{
    NSString *title;
    COMMON_BUTTON_TYPE myType;
}

@property BOOL flagModified;
@end

@implementation LWCommonButton


+(LWCommonButton *) buttonWithType:(UIButtonType) buttonType
{
    LWCommonButton *button=[super buttonWithType:UIButtonTypeCustom];
    button.flagModified=NO;
    
    button.clipsToBounds=YES;
    return button;
}


-(void) setTitle:(NSString *)_title forState:(UIControlState)state
{
    title=_title;
    [self update];
    
}

-(void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
}

-(void) setType:(COMMON_BUTTON_TYPE)type
{
    myType=type;
    [self update];
}

-(COMMON_BUTTON_TYPE) type
{
    return myType;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius=self.bounds.size.height/2;
    if(!self.flagModified)
        [self update];
    

}

-(void) update
{
    self.clipsToBounds=YES;
    self.flagModified=YES;
    self.layer.borderColor=[UIColor colorWithRed:229.0/255 green:239.0/255 blue:233.0/255 alpha:1].CGColor;
    self.layer.borderWidth=1;
    self.backgroundColor=[UIColor whiteColor];
    
    if(!title)
        title=self.titleLabel.text;
    
    NSDictionary *buttonEnabledAttributes;
    NSDictionary *buttonDisabledAttributes= @{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]};

    if(myType==BUTTON_TYPE_COLORED)
    {
        [self setBackgroundImage:[UIImage imageNamed:@"ButtonOK_square"] forState:UIControlStateNormal];
        [self setBackgroundImage:[self whiteImage] forState:UIControlStateDisabled];

        buttonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
    else if(myType==BUTTON_TYPE_CLEAR)
    {
        buttonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};

    }
    else if(myType==BUTTON_TYPE_GREEN)
    {
        self.backgroundColor=[UIColor colorWithRed:19.0/255 green:183.0/255 blue:42.0/255 alpha:1];
        buttonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
        
    }

    
    
    [super setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:buttonEnabledAttributes] forState:UIControlStateNormal];
    [super setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];

    

}

-(UIImage *) whiteImage
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    view.backgroundColor=[UIColor whiteColor];
    UIGraphicsBeginImageContextWithOptions(view.layer.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;

}




@end
