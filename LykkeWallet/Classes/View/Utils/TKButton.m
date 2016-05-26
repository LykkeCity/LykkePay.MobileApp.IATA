//
//  TKButton.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 25.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKButton.h"
#import "LWConstants.h"
#import "UIColor+Generic.h"


@interface TKButton () {
    
}


#pragma mark - Utils

- (void)updateImage;

@end


@implementation TKButton


#pragma mark - Properties

- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        [self.titleLabel setFont:_titleFont];
    }
}


#pragma mark - Customization

- (void)setGrayPalette {
    [self updateImage];
    
    UIColor *color = [UIColor colorWithHexString:kMainDarkElementsColor];
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (void)setColoredPalette {
    [self updateImage];
    
    UIColor *color = [UIColor whiteColor];
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (void)setGreenPalette {
    [self updateImage];
    
    UIColor *color = [UIColor whiteColor];
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (void)setDisabledPalette {
    [self updateImage];
    
    UIColor *color = [UIColor lightGrayColor];
    [self setTitleColor:color forState:UIControlStateNormal];
}


#pragma mark - Utils

- (void)updateImage {
    UIImage *image = [self backgroundImageForState:UIControlStateNormal];
    UIEdgeInsets const insets = UIEdgeInsetsMake(23, 23, 23, 23);
    UIImage *background = [image resizableImageWithCapInsets:insets];
    [self setBackgroundImage:background forState:UIControlStateNormal];
}

@end
