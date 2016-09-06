//
//  LWMyLykkeNewsCommonTableViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 31/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWMyLykkeNewsCommonTableViewCell.h"
#import "LWNewsElementModel.h"
#import "LWImageDownloader.h"
#import "NSDate+String.h"

@interface LWMyLykkeNewsCommonTableViewCell()
{
    LWNewsElementModel *newsElement;
}

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *author;

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView2;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *author2;

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView3;
@property (weak, nonatomic) IBOutlet UILabel *title3;
@property (weak, nonatomic) IBOutlet UILabel *author3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint3;

@property (weak, nonatomic) IBOutlet UIView *firstContainer;
@property (weak, nonatomic) IBOutlet UIView *secondContainer;
@property (weak, nonatomic) IBOutlet UIView *thirdContainer;


@end

@implementation LWMyLykkeNewsCommonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self orientationChanged];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerTapped:)];
    [_firstContainer addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerTapped:)];
    [_secondContainer addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerTapped:)];
    [_thirdContainer addGestureRecognizer:gesture];

    
}

-(void) update
{
    if(!newsElement)
        return;
    if(newsElement.imageURL)
        [[LWImageDownloader shared] downloadImageFromURLString:newsElement.imageURL.absoluteString withCompletion:^(UIImage *image){
            self.newsImageView.image=image;
        }];
    
    _title.text=newsElement.title;
    _author.text=[NSString stringWithFormat:@"%@ • %@", newsElement.author, [[NSDate date] timePassedFromDate:newsElement.date]];
    
    if(_element2)
    {
        if(_element2.imageURL)
            [[LWImageDownloader shared] downloadImageFromURLString:_element2.imageURL.absoluteString withCompletion:^(UIImage *image){
                self.newsImageView2.image=image;
            }];
        
        _title2.text=_element2.title;
        _author2.text=[NSString stringWithFormat:@"%@ • %@", _element2.author, [[NSDate date] timePassedFromDate:_element2.date]];

    }
    
    if(_element3)
    {
        if(_element3.imageURL)
            [[LWImageDownloader shared] downloadImageFromURLString:_element3.imageURL.absoluteString withCompletion:^(UIImage *image){
                self.newsImageView3.image=image;
            }];
        
        _title3.text=_element3.title;
        _author3.text=[NSString stringWithFormat:@"%@ • %@", _element3.author, [[NSDate date] timePassedFromDate:_element3.date]];
        
    }

    
}

-(void) setElement:(LWNewsElementModel *)element
{
    newsElement=element;
    [self update];

}

-(LWNewsElementModel *) element
{
    return newsElement;
}

-(void) setElement2:(LWNewsElementModel *)element2
{
    _element2=element2;
    [self update];
}

-(void) setElement3:(LWNewsElementModel *)element3
{
    _element3=element3;
    [self update];
}

-(void) hideEmpty
{
    if(!_element3)
        _thirdContainer.hidden=YES;
    if(!_element2)
        _secondContainer.hidden=YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) orientationChanged
{
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        self.imageViewHeightConstraint1.constant=162;
        self.imageViewHeightConstraint2.constant=162;
        self.imageViewHeightConstraint3.constant=162;
        
    }
    else
    {
        self.imageViewHeightConstraint1.constant=172;
        self.imageViewHeightConstraint2.constant=172;
        self.imageViewHeightConstraint3.constant=172;

    }
    
}

-(void) containerTapped:(UITapGestureRecognizer *) gesture
{
    if(gesture.view==_firstContainer)
        [self.delegate newsCellPressedElement:newsElement];
    else if(gesture.view==_secondContainer)
        [self.delegate newsCellPressedElement:_element2];
    else
        [self.delegate newsCellPressedElement:_element3];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





@end
