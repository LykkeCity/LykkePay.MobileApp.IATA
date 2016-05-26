//
//  LWLykkeEmptyTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 16.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kLykkeEmptyTableViewCell           @"LWLykkeEmptyTableViewCell"
#define kLykkeEmptyTableViewCellIdentifier @"LWLykkeEmptyTableViewCellIdentifier"


@class LWLykkeEmptyTableViewCell;


@protocol LWLykkeEmptyTableViewCellDelegate<NSObject>

@required
- (void)addLykkeClicked:(LWLykkeEmptyTableViewCell *)cell;

@end


@interface LWLykkeEmptyTableViewCell : TKTableViewCell {
    
}

#pragma mark - Properties

@property (nonatomic, weak) id<LWLykkeEmptyTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSString *issuerId;


#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet UILabel  *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *addWalletButton;

@end
