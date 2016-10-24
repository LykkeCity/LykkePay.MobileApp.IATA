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
    UIImageView *yellowDot;
    UIImageView *purpleDot;
    
}
@end

@implementation LWTradingLinearGraphViewTest

-(void) awakeFromNib
{
    [super awakeFromNib];
    yellowDot=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    yellowDot.image=[UIImage imageNamed:@"LinearGraphDotYellow"];
    [self addSubview:yellowDot];

    purpleDot=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    purpleDot.image=[UIImage imageNamed:@"LinearGraphDotPurple"];
    [self addSubview:purpleDot];
    yellowDot.hidden=YES;
    purpleDot.hidden=YES;
    
    

}

-(void) setChanges:(NSArray *)changes
{
    _changes=changes;
    minGraphY=40;
    maxGraphY=self.bounds.size.height-70;
    
    minValue=10000000;
    maxValue=0;
    
    for(NSDictionary *n in self.changes)
    {
        if([n[@"Ask"] floatValue]>maxValue)
            maxValue=[n[@"Ask"] floatValue];
        if([n[@"Bid"] floatValue]<minValue)
            minValue=[n[@"Bid"] floatValue];
    }
    
    if(maxValue==minValue)
        maxValue=maxValue+maxValue/1000;

}

-(void) layoutSubviews
{
    if(!_changes)
        return;
    CGSize size=self.frame.size;
    minGraphY=40;
    maxGraphY=self.bounds.size.height-70;

    yellowDot.hidden=NO;
    purpleDot.hidden=NO;
    
   CGFloat yAsk=[self point:[_changes.lastObject[@"Ask"] floatValue] forSize:size];
    CGFloat yBid=[self point:[_changes.lastObject[@"Bid"] floatValue] forSize:size];
    
    yellowDot.center=CGPointMake(self.bounds.size.width, yAsk);
    purpleDot.center=CGPointMake(self.bounds.size.width, yBid);
    
}

-(void) drawRect:(CGRect)rect
{

    CGContextRef context=UIGraphicsGetCurrentContext();
    
    int width=(int)CGBitmapContextGetWidth(context);
    int height=(int)CGBitmapContextGetHeight(context);
    
    unsigned char *bitmap=CGBitmapContextGetData(context);
    
    int step=(int)CGBitmapContextGetBytesPerRow(context);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);

    CGContextFillRect(context, (CGRect){CGPointZero, CGSizeMake(width, height)});
    
    NSDictionary *firstPoint = self.changes[0];
    NSDictionary *lastPoint = self.changes[self.changes.count - 1];

    
    CGContextSetRGBStrokeColor(context, 19.0/255, 183.0/255, 42.0/255, 1.0);
    CGContextSetRGBFillColor(context, 19.0/255, 183.0/255, 42.0/255, 1.0);
    
    if([firstPoint[@"Ask"] floatValue]>[lastPoint[@"Ask"] floatValue])
    {
        CGContextSetRGBStrokeColor(context, 255.0/255, 62.0/255, 46.0/255, 1.0);
        CGContextSetRGBFillColor(context, 255.0/255, 62.0/255,46.0/255, 1.0);
    }
    
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineWidth(context, 1);
    
    CGContextSetAllowsAntialiasing(context, false);
//    CGContextSetMiterLimit(context, 0);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    
    if(self.changes && self.changes.count >= 2)
    {
        CGFloat xPosition=0.0;
        CGFloat xMargin=0.0;
        CGSize const size=self.frame.size;
        CGFloat const xStep=(size.width-xMargin)/(self.changes.count-1);
        
        
        coeff=(maxValue-minValue)/(maxGraphY-minGraphY);
        
        
        CGContextSetRGBStrokeColor(context, 255.0/255, 174.0/255, 44.0/255, 1.0);
        CGContextSetRGBFillColor(context, 255.0/255, 174.0/255, 44.0/255, 1.0);

        
        
        CGFloat yPosition=[self point:[firstPoint[@"Ask"] floatValue] forSize:size];
        CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);
        
        for(NSDictionary *change in self.changes)
        {
            xPosition += xStep;

            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);

            yPosition=[self point:[change[@"Ask"] floatValue] forSize:size];
            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
        }
        
        

        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGPathRelease(pathRef);

        
        pathRef = CGPathCreateMutable();


        CGContextSetRGBStrokeColor(context, 171.0/255, 0.0/255, 255.0/255, 1.0);
        CGContextSetRGBFillColor(context, 171.0/255, 0.0/255,255.0/255, 1.0);
        
        xPosition=0;
        yPosition=[self point:[firstPoint[@"Bid"] floatValue] forSize:size];
        CGPathMoveToPoint(pathRef, NULL, xPosition, yPosition);
        
        for(NSDictionary *change in self.changes)
        {
            xPosition += xStep;
            
            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            
            yPosition=[self point:[change[@"Bid"] floatValue] forSize:size];
            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
        }

        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);

        
        
        CGPathRelease(pathRef);
    }
    
    if(!_changes)
        return;
    
    float r1=231;
    float g1=247;
    float b1=233;
    
    if([firstPoint[@"Ask"] floatValue]>[lastPoint[@"Ask"] floatValue])
    {
        r1=255;
        g1=235;
        b1=244;
    }
    
    for(int x=0;x<width;x++)
    {
        int mode=0;

        unsigned char *offset=bitmap+x*4;
        offset-=step;
        
        for(int y=0;y<height;y++)
        {
            offset+=step;
            
            if(*(offset+1)==(unsigned char)174)
            {
                mode=1;
                continue;
            }
            if(*(offset+1)==(unsigned char)0x0)
            {
                mode=2;
                continue;
            }
            
            if(mode==0)
            {
                float p=(float)(height-y)/height;
                
                r1=255;
                g1=247;
                b1=234;

                
                char r=(char)(255*p+(1-p)*255);
                char g=(char)(255*p+(1-p)*247);
                char b=(char)(255*p+(1-p)*234);
                
                
                
                *(offset)=b;
                *(offset+1)=g;
                *(offset+2)=r;
                continue;
            }
            if(mode==2)
            {
                float p=(float)(height-y)/height;
                
                r1=246;
                g1=229;
                b1=255;
                
                
                char r=(char)(r1*p+(1-p)*255);
                char g=(char)(g1*p+(1-p)*255);
                char b=(char)(b1*p+(1-p)*255);
                
                
                
                *(offset)=b;
                *(offset+1)=g;
                *(offset+2)=r;
                continue;
            }

            
        }
    }
    
    
}

- (CGFloat)point:(float) point forSize:(CGSize)size {
    
    float result=minGraphY+((point-minValue)/(maxValue-minValue))*(maxGraphY-minGraphY);
    result=size.height-result;
    return result;
}





@end
