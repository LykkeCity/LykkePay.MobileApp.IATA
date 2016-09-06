//
//  LWNewsFirstTableViewCell.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNewsFirstTableViewCell.h"
#import "LWNewsElementModel.h"
#import "LWImageDownloader.h"
#import "NSDate+String.h"

@interface LWNewsFirstTableViewCell()
{
    LWNewsElementModel *newsElement;
}

@property (weak, nonatomic) IBOutlet UIView *firstContainer;
@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;

@property (weak, nonatomic) IBOutlet UIView *secondContainer;
@property (weak, nonatomic) IBOutlet UIImageView *newsImageView2;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *author2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *equalWidthConstraint;



@end

@implementation LWNewsFirstTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerTapped:)];
    [_firstContainer addGestureRecognizer:gesture];
    gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerTapped:)];
    [_secondContainer addGestureRecognizer:gesture];
    [self update];
}

-(void) setElement:(LWNewsElementModel *)element
{
    newsElement=element;
    [self update];
}

-(void) update
{
    if(newsElement==nil)
        return;
    
    UIColor *color1=[UIColor whiteColor];
    UIColor *color2=[UIColor whiteColor];

    if(newsElement.imageURL)
        [[LWImageDownloader shared] downloadImageFromURLString:newsElement.imageURL.absoluteString withCompletion:^(UIImage *image){
            self.newsImageView.image=image;
        }];
    else
    {
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        {
        color1=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        color2=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
        }
        else if(self.equalWidthConstraint)
        {
            self.equalWidthConstraint.active=NO;
            self.equalWidthConstraint=nil;
            NSLayoutConstraint *constraint=[NSLayoutConstraint constraintWithItem:self.newsImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
            [self.newsImageView addConstraint:constraint];
        }
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        color1=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        color2=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
    }
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing:0] ;
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.maximumLineHeight=22;

    NSDictionary *attr=@{NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:21], NSForegroundColorAttributeName:[UIColor whiteColor]};

    
    NSMutableAttributedString *string=[[NSMutableAttributedString alloc] initWithString:newsElement.title attributes:nil];
    [string addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, string.length)];
    [string addAttributes:attr range:NSMakeRange(0, string.length)];
    
    
    _title.attributedText=string;
    
    _title.textColor=color1;
    self.author.textColor=color2;

    
//    _title.text=newsElement.title;
    _author.text=[NSString stringWithFormat:@"%@ • %@", newsElement.author, [[NSDate date] timePassedFromDate:newsElement.date]];

    _text.text=newsElement.text;
    
    
    if(_element2)
    {
        if(_element2.imageURL)
            [[LWImageDownloader shared] downloadImageFromURLString:_element2.imageURL.absoluteString withCompletion:^(UIImage *image){
                self.newsImageView2.image=image;
            }];
        self.title2.text=_element2.title;
        _author2.text=[NSString stringWithFormat:@"%@ • %@", _element2.author, [[NSDate date] timePassedFromDate:_element2.date]];

    }
    
    
    [self setNeedsLayout];
    
    

}

-(void) setElement2:(LWNewsElementModel *)element2
{
    _element2=element2;
    [self update];
}

-(LWNewsElementModel *) element
{
    return newsElement;
}

-(void) containerTapped:(UITapGestureRecognizer *) gesture
{
    if(gesture.view==_firstContainer)
        [self.delegate newsCellPressedElement:newsElement];
    else
        [self.delegate newsCellPressedElement:_element2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
