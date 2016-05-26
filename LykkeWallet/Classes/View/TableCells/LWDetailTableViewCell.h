//
//  LWDetailTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kDetailTableViewCell           @"LWDetailTableViewCell"
#define kDetailTableViewCellIdentifier @"LWDetailTableViewCellIdentifier"


@interface LWDetailTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleConstraint;


#pragma mark - Colorization

- (void)setWhitePalette;
- (void)setGrayPalette;


#pragma mark - Customization

- (void)setLightDetails;
- (void)setRegularDetails;
- (void)setNormalDetails;

@end
