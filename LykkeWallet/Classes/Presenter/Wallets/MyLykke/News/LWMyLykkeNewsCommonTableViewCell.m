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


@end

@implementation LWMyLykkeNewsCommonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self update];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
