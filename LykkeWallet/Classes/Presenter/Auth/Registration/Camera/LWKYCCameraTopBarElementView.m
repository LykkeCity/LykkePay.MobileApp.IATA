//
//  LWKYCCameraTopBarElementView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCCameraTopBarElementView.h"

@interface LWKYCCameraTopBarElementView()
{
    UIImageView *statusImageView;
    UILabel *label;
    UIView *underLineView;
    KYCDocumentType docType;
    KYCDocumentStatus docStatus;
    BOOL flagActive;
}

@end

@implementation LWKYCCameraTopBarElementView

-(id) init
{
    self=[super init];
    
    statusImageView=[[UIImageView alloc] init];
    [self addSubview:statusImageView];
    label=[[UILabel alloc] init];
    label.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    label.font=[UIFont fontWithName:@"ProximaNova-Regular" size:17];
    label.textAlignment=NSTextAlignmentCenter;
    [self addSubview:label];
    
    underLineView=[[UIView alloc] init];
    underLineView.backgroundColor=[UIColor colorWithRed:171.0/255 green:0 blue:1 alpha:1];
    [self addSubview:underLineView];
    
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    statusImageView.frame=CGRectMake(self.bounds.size.width/2-10, 15, 20, 20);
    label.frame=CGRectMake(0, 44, self.bounds.size.width, 20);
    underLineView.frame=CGRectMake(self.bounds.size.width/2-95/2, self.bounds.size.height-1.5, 95, 1.5);
    
}

-(void) setType:(KYCDocumentType)type
{
    docType=type;
    if(type==KYCDocumentTypeSelfie)
        label.text=@"Selfie";
    else if(type==KYCDocumentTypePassport)
        label.text=@"Passport";
    else if(type==KYCDocumentTypeAddress)
        label.text=@"Address";
    
}

-(void) setIsActive:(BOOL)isActive
{
    flagActive=isActive;
    underLineView.hidden=!flagActive;
    if(flagActive)
        label.alpha=1;
    else
        label.alpha=0.6;
}

-(void) setStatus:(KYCDocumentStatus)status
{
    docStatus=status;
    statusImageView.hidden=NO;
    
    if(status==KYCDocumentStatusUploaded || status==KYCDocumentStatusApproved)
        statusImageView.image=[UIImage imageNamed:@"KYCStatusUploadedIcon"];
    else if(status==KYCDocumentStatusRejected)
        statusImageView.image=[UIImage imageNamed:@"KYCStatusRejectedIcon"];
    else
        statusImageView.hidden=YES;
}

-(KYCDocumentStatus) status
{
    return docStatus;
}

-(BOOL) isActive
{
    return flagActive;
}

-(KYCDocumentType) type
{
    return docType;
}


@end
