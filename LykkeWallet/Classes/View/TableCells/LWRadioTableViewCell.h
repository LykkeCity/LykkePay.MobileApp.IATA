//
//  LWRadioTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kRadioTableViewCell           @"LWRadioTableViewCell"
#define kRadioTableViewCellIdentifier @"LWRadioTableViewCellIdentifier"


@protocol LWRadioTableViewCellDelegate <NSObject>

@required
- (void)switcherChanged:(BOOL)isOn;

@end


@interface LWRadioTableViewCell : TKTableViewCell {
    
}


#pragma mark - Properties

@property (weak, nonatomic) id<LWRadioTableViewCellDelegate> delegate;


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *radioSwitch;


#pragma mark - General

- (void)setSwitcherOn:(BOOL)isOn;

@end
