//
//  LWSettingsCallSupportTableViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"

#define kSettingsCallSupportTableViewCell           @"LWSettingsCallSupportTableViewCell"
#define kSettingsCallSupportTableViewCellIdentifier @"LWSettingsCallSupportTableViewCellIdentifier"


@interface LWSettingsCallSupportTableViewCell : TKTableViewCell

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;


@end
