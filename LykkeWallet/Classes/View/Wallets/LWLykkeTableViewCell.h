//
//  LWLykkeTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 28.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "SWTableViewCell.h"


#define kLykkeTableViewCell           @"LWLykkeTableViewCell"
#define kLykkeTableViewCellIdentifier @"LWLykkeTableViewCellIdentifier"


@class LWLykkeTableViewCell;


@protocol LWLykkeTableViewCellDelegate<NSObject>

@required
- (void)addLykkeItemClicked:(LWLykkeTableViewCell *)cell;

@end


@interface LWLykkeTableViewCell : SWTableViewCell {
    
}

#pragma mark - Identity

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;


#pragma mark - Properties

@property (weak, nonatomic) id<LWLykkeTableViewCellDelegate> cellDelegate;


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel  *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel  *walletBalanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addWalletButton;

@end
