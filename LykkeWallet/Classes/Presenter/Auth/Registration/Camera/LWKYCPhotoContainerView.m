//
//  LWKYCPhotoContainerView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/09/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWKYCPhotoContainerView.h"

@interface LWKYCPhotoContainerView()
{
    UIImageView *imageView;
    UIView *shadowView;
    UIImageView *photoImageView;
    UILabel *titleBadLabel;
    UILabel *descriptionLabel;
    UILabel *titleLabel;
    KYCDocumentStatus currentMode;
}

@end

@implementation LWKYCPhotoContainerView

-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    
    [self createViews];
    return self;
}

-(void) createViews
{
    self.layer.cornerRadius=2.5;
    self.clipsToBounds=YES;
    imageView=[[UIImageView alloc] initWithFrame:self.bounds];
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    if(_image)
        imageView.image=_image;
    [self addSubview:imageView];
    
    shadowView=[[UIView alloc] initWithFrame:self.bounds];
    shadowView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowView.backgroundColor=[UIColor colorWithRed:1 green:174.0/255 blue:44.0/255 alpha:0.9];
    [self addSubview:shadowView];
    
    photoImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KYCBadImageIcon"]];
    photoImageView.frame=CGRectMake(0, 0, 90, 90);
    photoImageView.contentMode=UIViewContentModeCenter;
    [self addSubview:photoImageView];
    
    titleBadLabel=[[UILabel alloc] init];
    titleBadLabel.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:14];
    titleBadLabel.textColor=[UIColor whiteColor];
    titleBadLabel.text=@"Photo failed!";
    titleBadLabel.textAlignment=NSTextAlignmentCenter;
    [titleBadLabel sizeToFit];
    [self addSubview:titleBadLabel];
    
    descriptionLabel=[[UILabel alloc] init];
    descriptionLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    descriptionLabel.textColor=[UIColor whiteColor];
    descriptionLabel.numberOfLines=0;
    descriptionLabel.alpha=0.6;
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.numberOfLines=0;
    titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    titleLabel.textColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.6];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    if(_title)
        titleLabel.text=_title;
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    if(_failedDescription)
    {
        descriptionLabel.text=_failedDescription;
        [descriptionLabel sizeToFit];
    }
    [self addSubview:descriptionLabel];

}

-(void) awakeFromNib
{
    [super awakeFromNib];
    [self createViews];
}


-(void) setStatus:(KYCDocumentStatus)mode
{
    currentMode=mode;
    [self adjustMode];
}

-(KYCDocumentStatus) status
{
    return currentMode;
}

-(void) adjustMode
{
    if(currentMode==KYCDocumentStatusEmpty)
    {
        self.backgroundColor=[UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
        self.layer.borderColor=[UIColor colorWithWhite:216.0/255 alpha:1].CGColor;
        self.layer.borderWidth=0.5;
        photoImageView.image=[UIImage imageNamed:@"KYCCameraIcon"];
        titleBadLabel.hidden=YES;
        photoImageView.hidden=NO;
        descriptionLabel.hidden=YES;
        shadowView.hidden=YES;
        imageView.hidden=YES;
        titleLabel.hidden=NO;
    }
    else if(currentMode==KYCDocumentStatusRejected)
    {
        self.backgroundColor=nil;
        self.layer.borderColor=nil;
        photoImageView.image=[UIImage imageNamed:@"KYCBadImageIcon"];
        titleBadLabel.hidden=NO;
        photoImageView.hidden=NO;
        descriptionLabel.hidden=NO;
        shadowView.hidden=NO;
        imageView.hidden=NO;
        titleLabel.hidden=YES;
    }
    else if(currentMode==KYCDocumentStatusUploaded || currentMode==KYCDocumentStatusApproved)
    {
        self.backgroundColor=nil;
        self.layer.borderColor=nil;
    
        titleBadLabel.hidden=YES;
        photoImageView.hidden=YES;
        descriptionLabel.hidden=YES;
        shadowView.hidden=YES;
        imageView.hidden=NO;
        titleLabel.hidden=YES;
    }
    
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    photoImageView.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2-25);
    CGSize titleSize=[titleLabel sizeThatFits:CGSizeMake(self.bounds.size.width-60, 1000)];
    titleLabel.frame=CGRectMake(0, 0, titleSize.width, titleSize.height);
    titleLabel.center=CGPointMake(self.bounds.size.width/2, photoImageView.frame.origin.y+photoImageView.bounds.size.height+10+titleLabel.bounds.size.height/2);
    titleBadLabel.center=CGPointMake(self.bounds.size.width/2, photoImageView.frame.origin.y+photoImageView.bounds.size.height+10+titleBadLabel.bounds.size.height/2);
    
    CGSize size=[descriptionLabel sizeThatFits:CGSizeMake(self.bounds.size.width-60, 1000)];
    descriptionLabel.frame=CGRectMake(0, 0, size.width, size.height);
    descriptionLabel.center=CGPointMake(self.bounds.size.width/2, titleBadLabel.frame.origin.y+titleBadLabel.bounds.size.height+10+descriptionLabel.bounds.size.height/2);
}

-(void) setImage:(UIImage *)image
{
    _image=image;
    imageView.image=image;
}

-(void) setTitle:(NSString *)title
{
    _title=title;
    titleLabel.text=title;
    [titleLabel sizeToFit];
    [self setNeedsLayout];
}

-(void) setFailedDescription:(NSString *)failedDescription
{
    _failedDescription=failedDescription;
    descriptionLabel.text=_failedDescription;
    
    [self setNeedsLayout];
}



@end
