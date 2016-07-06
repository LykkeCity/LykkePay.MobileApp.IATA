//
//  LWTradingLinearGraphViewTest.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTradingLinearGraphViewTest.h"

@interface LWTradingLinearGraphViewTest()
{
    CGFloat minGraphY;
    CGFloat maxGraphY;
    float coeff;
    float minValue;
    float maxValue;
    
}
@end

@implementation LWTradingLinearGraphViewTest

-(void) drawRect:(CGRect)rect
{

    CGContextRef context=UIGraphicsGetCurrentContext();
    
    int width=(int)CGBitmapContextGetWidth(context);
    int height=(int)CGBitmapContextGetHeight(context);
    
    unsigned char *bitmap=CGBitmapContextGetData(context);
    
    int step=(int)CGBitmapContextGetBytesPerRow(context);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);

    CGContextFillRect(context, (CGRect){CGPointZero, CGSizeMake(width, height)});
    
    NSNumber *firstPoint = self.changes[0];
    NSNumber *lastPoint = self.changes[self.changes.count - 1];

    
    CGContextSetRGBStrokeColor(context, 18.0/255, 183.0/255, 42.0/255, 1.0);
    CGContextSetRGBFillColor(context, 18.0/255, 183.0/255, 42.0/255, 1.0);
    
    if(firstPoint.floatValue>lastPoint.floatValue)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255, 62.0/255, 45.0/255, 1.0);
        CGContextSetRGBFillColor(context, 255.0/255, 62.0/255,45.0/255, 1.0);
    }
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 2.0);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    
    if(self.changes && self.changes.count >= 2)
    {
        CGFloat xPosition=0.0;
        CGFloat xMargin=0.0;
        CGSize const size=self.frame.size;
        CGFloat const xStep=(size.width-xMargin)/(self.changes.count-1);
        
        minGraphY=self.bounds.size.height*0.40;
        maxGraphY=self.bounds.size.height-70;
        
        minValue=1000000;
        maxValue=0;
        
        for(NSNumber *n in self.changes)
        {
            if([n floatValue]>maxValue)
                maxValue=n.floatValue;
            if(n.floatValue<minValue)
                minValue=n.floatValue;
        }
        
        if(maxValue==minValue)
            maxValue=maxValue+maxValue/1000;
        
        coeff=(maxValue-minValue)/(maxGraphY-minGraphY);
        
        
        
        CGPathMoveToPoint(pathRef, NULL, xPosition, [self point:firstPoint.floatValue forSize:size]);
        
        for(NSNumber *change in self.changes)
        {
            CGFloat yPosition=[self point:[change floatValue] forSize:size];
            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            xPosition += xStep;
        }
        
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGPathRelease(pathRef);
    }
    
    float r1=244;
    float g1=248;
    float b1=234;
    
    if(firstPoint.floatValue>lastPoint.floatValue)
    {
        r1=251;
        g1=169;
        b1=209;
    }
    
    for(int x=0;x<width;x++)
    {
        unsigned char *offset=bitmap+x*4;
        BOOL found=NO;
        for(int y=0;y<height;y++)
        {
            char p1=*offset;
            
            if(p1!=(char)0xff)
            {
                found=YES;
            }
            if(found && p1==(char)0xff)
            {
                
                //R = firstCol.R * p + secondCol.R * (1 - p)
                
                float p=(float)(height-y)/height;
                
                char r=(char)(r1*p+(1-p)*255);
                char g=(char)(g1*p+(1-p)*255);
                char b=(char)(b1*p+(1-p)*255);
                
                
                *(offset)=b;
                *(offset+1)=g;
                *(offset+2)=r;
            }
            if(!found)
            {
                char w=(char)0xff;
                *(offset)=w;
                *(offset+1)=w;
                *(offset+2)=w;
                
            }
            
            offset+=step;
        }
    }
    
    
}

- (CGFloat)point:(float) point forSize:(CGSize)size {
    
    float result=minGraphY+((point-minValue)/(maxValue-minValue))*(maxGraphY-minGraphY);
    result=size.height-result;
    return result;
}





@end
