//
//  LWKYCCameraTopBarView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCCameraTopBarView.h"
#import "LWKYCCameraTopBarElementView.h"

@interface LWKYCCameraTopBarView()
{
    BOOL flagViewsCreated;
    NSMutableArray *views;
    UIView *bottomLineView;
}

@end

@implementation LWKYCCameraTopBarView

-(id) init
{
    self=[super init];
    flagViewsCreated=NO;
    return self;
}


-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    flagViewsCreated=NO;
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    if(!flagViewsCreated)
        [self createViews];
    CGFloat width=self.bounds.size.width/3;
    for(int i=0;i<3;i++)
    {
        LWKYCCameraTopBarElementView *v=views[i];
        v.frame=CGRectMake(width*i, 0, width, self.bounds.size.height);
    }
    bottomLineView.frame=CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5);
}


-(void) createViews
{
    
    flagViewsCreated=YES;
    
    self.backgroundColor=[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
    
    bottomLineView=[[UIView alloc] init];
    bottomLineView.backgroundColor=[UIColor colorWithWhite:216.0/255 alpha:1];
    [self addSubview:bottomLineView];

    views=[[NSMutableArray alloc] init];
    LWKYCCameraTopBarElementView *v=[LWKYCCameraTopBarElementView new];
    v.type=KYCDocumentTypeSelfie;
    [views addObject:v];
    v=[LWKYCCameraTopBarElementView new];
    v.type=KYCDocumentTypePassport;
    [views addObject:v];
    v=[LWKYCCameraTopBarElementView new];
    v.type=KYCDocumentTypeSelfie;
    [views addObject:v];
    for(UIView *v in views)
        [self addSubview:v];
    
    
}




@end
