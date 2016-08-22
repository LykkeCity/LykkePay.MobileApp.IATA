//
//  LWNumbersKeyboardViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 21/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNumbersKeyboardViewCell.h"

@implementation LWNumbersKeyboardViewCell



-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.backgroundColor=[UIColor lightGrayColor];
    if(self.tag>0 && self.tag<=10)
    {
        NSString *symbol=[@(self.tag) stringValue];
        if(self.tag==10)
            symbol=@"0";
        [self.delegate numberCellPressedSymbol:symbol];
    }
    else
        [self.delegate numberCellPressedBackspace];
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


@end
