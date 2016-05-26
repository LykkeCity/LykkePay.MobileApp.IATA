//
//  LWTradingLinearGraphView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTradingLinearGraphView.h"

@interface LWTradingLinearGraphView()
{
    CGFloat minGraphY;
    CGFloat maxGraphY;
    float coeff;
    float minValue;
    float maxValue;

}

@end

@implementation LWTradingLinearGraphView

-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    self.backgroundColor=[UIColor yellowColor];
    
    return self;
    
}

- (void)drawRect:(CGRect)rect {
    
    if (self.changes && self.changes.count >= 2) {
        // calculation preparation
        CGFloat xPosition = 0.0;
        CGFloat xMargin = 0.0;
        CGSize const size = self.frame.size;
        CGFloat const xStep = (size.width - xMargin) / (self.changes.count - 1);
        NSNumber *firstPoint = self.changes[0];
        
        minGraphY=self.bounds.size.height*0.2;
        maxGraphY=self.bounds.size.height*0.6;
        
        minValue=1000000;
        maxValue=0;
        
        for(NSNumber *n in self.changes)
        {
            if([n floatValue]>maxValue)
                maxValue=n.floatValue;
            if(n.floatValue<minValue)
                minValue=n.floatValue;
        }
        
        coeff=(maxValue-minValue)/(maxGraphY-minGraphY);
        
        NSNumber *lastPoint = self.changes[self.changes.count - 1];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 2;
        [path moveToPoint:CGPointMake(xPosition, [self point:firstPoint.floatValue forSize:size])];
        
        // prepare drawing data
        for (NSNumber *change in self.changes) {
            CGFloat const yPosition = [self point:[change floatValue] forSize:size];
            [path addLineToPoint:CGPointMake(xPosition, yPosition)];
            xPosition += xStep;
        }
        
        UIColor *color = nil;
        // set negative or positive color
        if (firstPoint.doubleValue >= lastPoint.doubleValue) {
            color = [UIColor greenColor];
        }
        else {
            color = [UIColor redColor];
        }
        // draw
        [color setStroke];
        [path stroke];
        
        // draw last point
        CGRect rect = CGRectMake(xPosition - xStep - 5.0, [self point:lastPoint.floatValue  forSize:size] - 3.0, 6.0, 6.0);
        UIBezierPath *cicle = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        [color set];
        [cicle fill];
        
        
    }
}

- (CGFloat)point:(float) point forSize:(CGSize)size {
    
    float result=minGraphY+((point-minValue)/(maxValue-minValue))*(maxGraphY-minGraphY);
    return result;
//    
//    
//    
//    CGFloat const yMargin = 4.0;
//    CGFloat const yMarginPercantage = 1.0 + yMargin * 0.01;
//    CGFloat result = (size.height - yMargin) * (yMarginPercantage - point.doubleValue);
//    return result;
}


@end
