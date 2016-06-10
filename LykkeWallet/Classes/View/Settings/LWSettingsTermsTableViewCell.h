//
//  LWSettingsTermsTableViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 10/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"

#define kSettingsTermsTableViewCell @"LWSettingsTermsTableViewCell"
#define kSettingsTermsTableViewCellIdentifier @"LWSettingsTermsTableViewCellIdentifier"

#define kTermsOfUseURL @"https://lykkewallet.lykkex.com/terms_of_use.html"

@interface LWSettingsTermsTableViewCell : TKTableViewCell

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *termsLabel;

@end
