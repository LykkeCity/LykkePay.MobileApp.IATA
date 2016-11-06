//
//  LWAssetLykkeTableChangeView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 18.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetLykkeTableChangeView.h"
#import "LWConstants.h"
#import "LWColorizer.h"


@interface LWAssetLykkeTableChangeView () {
    
}

@end

@implementation LWAssetLykkeTableChangeView

- (void)drawRect:(CGRect)rect {
    
    if (self.changes && self.changes.count >= 2) {
        // calculation preparation
        CGFloat xPosition = 0.0;
        CGFloat xMargin = 5.0;
        CGSize const size = self.frame.size;
        CGFloat const xStep = (size.width - xMargin) / (self.changes.count - 1);
        NSNumber *firstPoint = self.changes[0];
        NSNumber *lastPoint = self.changes[self.changes.count - 1];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 0.5;
        [path moveToPoint:CGPointMake(xPosition, [self point:firstPoint forSize:size])];
        
        // prepare drawing data
        for (NSNumber *change in self.changes) {
            CGFloat const yPosition = [self point:change forSize:size];
            [path addLineToPoint:CGPointMake(xPosition, yPosition)];
            xPosition += xStep;
        }
        
        UIColor *color = nil;
        // set negative or positive color
        if (firstPoint.doubleValue >= lastPoint.doubleValue) {
            color = [UIColor colorWithHexString:kAssetChangeMinusColor];
        }
        else {
            color = [UIColor colorWithHexString:kAssetChangePlusColor];
        }
        // draw
        [color setStroke];
        [path stroke];
        
        // draw last point
        CGRect rect = CGRectMake(xPosition - xStep - 1.0, [self point:lastPoint forSize:size] - 1.0, 2.0, 2.0);
        UIBezierPath *cicle = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        [color set];
        [cicle fill];
    }
}

- (CGFloat)point:(NSNumber *)point forSize:(CGSize)size {
    CGFloat const yMargin = 4.0;
    CGFloat const yMarginPercantage = 1.0 + yMargin * 0.01;
    CGFloat result = (size.height - yMargin) * (yMarginPercantage - point.doubleValue);
    return result;
}

@end
