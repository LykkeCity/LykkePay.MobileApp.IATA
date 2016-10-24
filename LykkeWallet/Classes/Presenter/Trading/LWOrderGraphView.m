//
//  LWOrderGraphView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWOrderGraphView.h"
#import "LWUtils.h"
#import "LWCache.h"

@interface LWOrderGraphView()
{
    double volume;
    double price;
    UILabel *priceLabel;
    UILabel *volumeLabel;
    CGFloat depthStartX;
}

@end

@implementation LWOrderGraphView

-(id) initWithPrice:(double) _price volume:(double) _volume
{
    self=[super init];
    price=_price;
    volume=_volume;
    _graphStartOffset=115;
    depthStartX=187;
    
    return self;
}

-(void) setAssetPair:(LWAssetPairModel *)assetPair
{
    _assetPair=assetPair;
    priceLabel=[[UILabel alloc] init];
    
    NSString *formatString=[NSString stringWithFormat:@"%d",[self.assetPair.accuracy intValue]];
    formatString=[[@"%." stringByAppendingString:formatString] stringByAppendingString:@"lf"];
    NSString *priceString=[NSString stringWithFormat:formatString, price];
    priceLabel.text=priceString;
    priceLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    priceLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    [priceLabel sizeToFit];
    [self addSubview:priceLabel];
    
    volumeLabel=[[UILabel alloc] init];
    volumeLabel.font=priceLabel.font;
    volumeLabel.textColor=_volumeColor;
    
    NSString *volumeString=@"";
    int left=volume;;
    while(1)
    {
        int ii=left/1000;
        NSString *s=[NSString stringWithFormat:@"%d", left-ii*1000];
        if(ii==0)
        {
            volumeString=[s stringByAppendingString:volumeString];
            break;
        }

        while(s.length<3)
            s=[@"0" stringByAppendingString:s];
        volumeString=[[@"," stringByAppendingString:s] stringByAppendingString:volumeString];
        left=ii;
    }
    
    volumeLabel.text=volumeString;
    [self addSubview:volumeLabel];
    [volumeLabel sizeToFit];

}

-(void) layoutSubviews
{
    [super layoutSubviews];
    priceLabel.frame=CGRectMake(30, 0, priceLabel.bounds.size.width, self.bounds.size.height);
    volumeLabel.frame=CGRectMake(130, 0, volumeLabel.bounds.size.width, self.bounds.size.height);
}

-(void) drawRect:(CGRect)rect
{
    
    CGFloat* components = CGColorGetComponents(_graphColor.CGColor);
    
    float r1=components[0]*255;
    float g1=components[1]*255;
    float b1=components[2]*255;
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    int width=(int)CGBitmapContextGetWidth(context);
    int height=(int)CGBitmapContextGetHeight(context);
    
    int step=(int)CGBitmapContextGetBytesPerRow(context);

    
    unsigned char *bitmap=CGBitmapContextGetData(context);

    int startX=(width/self.bounds.size.width)*_graphStartOffset;
    int endX;//=(width/self.bounds.size.width)*(depthStartX+(self.bounds.size.width-depthStartX-30)*(volume/_graphMaxVolume));
    
    if(_graphMaxVolume==_graphMinVolume)
        endX=(width/self.bounds.size.width)*((self.bounds.size.width-30)+depthStartX)/2;
    else
        endX=([LWUtils logarithmicValueFrom:volume min:_graphMinVolume max:_graphMaxVolume length:self.bounds.size.width-depthStartX-30]+depthStartX)*(width/self.bounds.size.width);
    
    CGFloat *components2 = CGColorGetComponents(_volumeColor.CGColor);
    float r2=components2[0]*255;
    float g2=components2[1]*255;
    float b2=components2[2]*255;

    
    for(int x=0;x<width;x++)
    {
        
        float p;
        char r;
        char g;
        char b;
        if(x<startX || x>endX+2)
        {
            r=0xff;
            g=0xff;
            b=0xff;
        }
        else if(x>=endX && x<=endX+2)
        {
            
            r=r2;
            g=g2;
            b=b2;
        }
        else
        {
            p=(float)(x-startX)/(endX-startX);
            r=(char)(r1*p+(1.0-p)*255);
            g=(char)(g1*p+(1.0-p)*255);
            b=(char)(b1*p+(1.0-p)*255);
        }
        
        unsigned char *offset=bitmap+x*4;
        
        
        for(int y=0;y<height;y++)
        {
            *(offset)=b;
            *(offset+1)=g;
            *(offset+2)=r;
            offset+=step;
        }

    }
}


@end
