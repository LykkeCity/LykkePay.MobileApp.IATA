//
//  LWPINButtonView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPINButtonView.h"

@interface LWPINButtonView()

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *lettersLabel;

@end

@implementation LWPINButtonView



-(void) awakeFromNib
{
    self.layer.cornerRadius=self.bounds.size.height/2;
    if(self.tag<11)
    {
        self.layer.borderColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1].CGColor;
        self.layer.borderWidth=1;
    }
    self.backgroundColor=[UIColor whiteColor];
    if(_lettersLabel)
    {
        if([UIScreen mainScreen].bounds.size.width==320)
            self.lettersLabel.attributedText=[[NSAttributedString alloc] initWithString:_lettersLabel.text attributes:@{NSKernAttributeName:@(1.8)}];
        else
            self.lettersLabel.attributedText=[[NSAttributedString alloc] initWithString:_lettersLabel.text attributes:@{NSKernAttributeName:@(1.8), NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6], NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Regular" size:17]}];

    }

}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.backgroundColor=[UIColor lightGrayColor];
    if(self.tag<=10)
    {
        if(self.tag<10)
            [self.delegate pinButtonViewPressedButtonWithSymbol:[NSString stringWithFormat:@"%d",(int)self.tag]];
        else
            [self.delegate pinButtonViewPressedButtonWithSymbol:@"0"];
    }
    else if(self.tag==11)
        [self.delegate pinButtonPressedFingerPrint];
    else if(self.tag==12)
        [self.delegate pinButtonViewPressedDelete];

}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.backgroundColor=[UIColor whiteColor];
    
}

-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.backgroundColor=[UIColor whiteColor];
}

-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end
