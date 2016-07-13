//
//  LWWalletsTypeButton.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWalletsTypeButton.h"

@interface LWWalletsTypeButton()
{
    UIImage *normalImage;
    UIImage *selectedImage;
}

@end


@implementation LWWalletsTypeButton

-(id) initWithTitle:(NSString *) title
{
    self=[super initWithFrame:CGRectMake(0, 0, 99, 30)];
    
    UIView *view=[[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor=nil;
    
    UILabel *label=[[UILabel alloc] initWithFrame:self.bounds];
    label.textAlignment=NSTextAlignmentCenter;
    
    NSDictionary *attributes=@{NSKernAttributeName:@(1.1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:13], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
    label.attributedText=[[NSAttributedString alloc] initWithString:title attributes:attributes];
    
    [view addSubview:label];
    
    normalImage=[self render:view];
    
    
    NSDictionary *attributesActive=@{NSKernAttributeName:@(1.1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:13], NSForegroundColorAttributeName:[UIColor whiteColor]};
    label.attributedText=[[NSAttributedString alloc] initWithString:title attributes:attributesActive];

    view.backgroundColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    view.layer.cornerRadius=view.bounds.size.height/2;
    view.clipsToBounds=YES;
    
    selectedImage=[self render:view];
    
    [self setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [self setBackgroundImage:selectedImage forState:UIControlStateFocused];
    
    return self;
}

-(UIImage *) render:(UIView *) view
{
    
    UIGraphicsBeginImageContextWithOptions(view.layer.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

@end
