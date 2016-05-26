//
//  LWBitcoinTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 15.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "SWTableViewCell.h"


#define kBitcoinTableViewCell           @"LWBitcoinTableViewCell"
#define kBitcoinTableViewCellIdentifier @"LWBitcoinTableViewCellIdentifier"


@class LWBitcoinTableViewCell;

@protocol LWBitcoinTableViewCellDelegate<NSObject>

@required
- (void)addBitcoinClicked:(LWBitcoinTableViewCell *)cell;

@end


@interface LWBitcoinTableViewCell : SWTableViewCell {
    
}

#pragma mark - Identity

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

#pragma mark - Properties

@property (weak, nonatomic) id<LWBitcoinTableViewCellDelegate> cellDelegate;

#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet UILabel *bitcoinLabel;
@property (nonatomic, weak) IBOutlet UILabel *bitcoinBalance;
@property (nonatomic, weak) IBOutlet UIButton *bitcoinAddButton;

@end
