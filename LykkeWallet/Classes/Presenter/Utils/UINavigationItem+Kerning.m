//
//  UINavigationItem+Kerning.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "UINavigationItem+Kerning.h"
#import "LWConstants.h"
#import "UIColor+Generic.h"

@implementation UINavigationItem(Kerning)

-(void) setTitleWithKerning:(NSString *)title
{
    UIFont *font = [UIFont fontWithName:kNavigationBarFontName size:kNavigationBarFontSize];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithHexString:kNavigationBarFontColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                @(1.5f), NSKernAttributeName,
                                nil];
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.attributedText=[[NSAttributedString alloc] initWithString:title attributes:attributes];
    [titleLabel sizeToFit];
//    self.titleView=titleLabel;
    
    UIImageView *iiii=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ButtonOK_square.png"]];
    iiii.frame=CGRectMake(0, 0, 100, 20);
    self.titleView=iiii;
}

@end
