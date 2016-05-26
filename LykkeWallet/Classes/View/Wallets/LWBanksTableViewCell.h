//
//  LWBanksTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 28.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kBanksTableViewCell           @"LWBanksTableViewCell"
#define kBanksTableViewCellIdentifier @"LWBanksTableViewCellIdentifier"


@interface LWBanksTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *cardNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardDigitsLabel;

@end
