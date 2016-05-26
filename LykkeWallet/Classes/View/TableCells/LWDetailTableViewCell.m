//
//  LWDetailTableViewCell.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWDetailTableViewCell.h"
#import "LWConstants.h"
#import "UIColor+Generic.h"


@implementation LWDetailTableViewCell {
    
}


#pragma mark - Colorization

- (void)setWhitePalette {
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setGrayPalette {
    [self setBackgroundColor:[UIColor colorWithHexString:kMainGrayElementsColor]];
}


#pragma mark - Customization

- (void)setLightDetails {
    UIFont *font = [UIFont fontWithName:kTableCellLightFontName
                                   size:kTableCellDetailFontSize];
    [self.detailLabel setFont:font];
}

- (void)setRegularDetails {
    UIFont *font = [UIFont fontWithName:kTableCellRegularFontName
                                   size:kTableCellDetailFontSize];
    [self.detailLabel setFont:font];
}

- (void)setNormalDetails {
    UIFont *font = [UIFont fontWithName:kTableCellRegularFontName
                                   size:kTableCellTransferFontSize];
    [self.detailLabel setFont:font];
}

@end
