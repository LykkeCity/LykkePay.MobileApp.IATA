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
    KYCDocumentType currentType;
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

-(void) setDocumentsStatuses:(LWKYCDocumentsModel *)documentsStatuses
{
    _documentsStatuses=documentsStatuses;
    [self adjustStatuses];
}

-(void) setActiveType:(KYCDocumentType)activeType
{
    currentType=activeType;
    [self adjustCurrentType];
}

-(KYCDocumentType) activeType
{
    return currentType;
}

-(void) adjustStatuses
{

    [(LWKYCCameraTopBarElementView *)views[0] setStatus:[_documentsStatuses statusForDocument:KYCDocumentTypeSelfie]];
    [(LWKYCCameraTopBarElementView *)views[1] setStatus:[_documentsStatuses statusForDocument:KYCDocumentTypeIdCard]];
    [(LWKYCCameraTopBarElementView *)views[2] setStatus:[_documentsStatuses statusForDocument:KYCDocumentTypeProofOfAddress]];

    
//    [self setActiveType:[_documentsStatuses[@"ActiveType"] intValue]];
}

-(void) adjustCurrentType
{
    for(LWKYCCameraTopBarElementView *v in views)
        v.isActive=v.type==currentType;
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
    v.type=KYCDocumentTypeIdCard;
    [views addObject:v];
    v=[LWKYCCameraTopBarElementView new];
    v.type=KYCDocumentTypeProofOfAddress;
    [views addObject:v];
    for(UIView *v in views)
        [self addSubview:v];
    if(_documentsStatuses)
        [self adjustStatuses];
    [self adjustCurrentType];
    
    for(LWKYCCameraTopBarElementView *v in views)
    {
        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(elementTapped:)];
        [v addGestureRecognizer:gesture];
    }
    
}

-(void) elementTapped:(UITapGestureRecognizer *) gesture
{
    LWKYCCameraTopBarElementView *v=(LWKYCCameraTopBarElementView *)gesture.view;
    [self.delegate kycTopBarViewPressedDocumentType:v.type];
}






@end
