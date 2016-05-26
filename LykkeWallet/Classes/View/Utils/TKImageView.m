//
//  TKImageView.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 03.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKImageView.h"


@interface TKImageView () {
    UIImageView *imageView;
    UIActivityIndicatorView *activityView;
}

@end


@implementation TKImageView


#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        [self addSubview:imageView];
    }
    if (!activityView) {
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        activityView.hidesWhenStopped = YES;
        [activityView stopAnimating];
        
        [self addSubview:activityView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    imageView.frame = self.bounds;
    activityView.frame = self.bounds;
}


#pragma mark - TKView

- (void)reloadData {
    [activityView startAnimating];
    
    __weak typeof(self) welf = self;
    dispatch_queue_t q = dispatch_queue_create("TKImageView.load", 0);
    dispatch_async(q, ^{
        UIImage *img = welf.loadingBlock();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityView stopAnimating];
            // setup image
            imageView.image = img;
        });
    });
}

@end
