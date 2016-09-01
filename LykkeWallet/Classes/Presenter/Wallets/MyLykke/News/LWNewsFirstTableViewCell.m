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

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;

@end

@implementation LWNewsFirstTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.title.textColor=[UIColor whiteColor];
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
        color1=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
        color2=[UIColor colorWithRed:140.0/255 green:148.0/255 blue:160.0/255 alpha:1];
//        [self.newsImageView removeConstraint:self.imageViewHeight];
//        [self.newsImageView removeFromSuperview];
//        NSLayoutConstraint *constraint=[NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.title.superview attribute:NSLayoutAttributeTop multiplier:1 constant:25];
//        [self.title.superview addConstraint:constraint];
        
        
//        NSArray *ccc=self.newsImageView.superview.constraints;
//        for(NSLayoutConstraint *c in ccc)
//            if(c.firstItem==_newsImageView || c.secondItem==_newsImageView)
//            {
//                [_newsImageView.superview removeConstraint:c];
//            }
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
    [self setNeedsLayout];

}

-(LWNewsElementModel *) element
{
    return newsElement;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
