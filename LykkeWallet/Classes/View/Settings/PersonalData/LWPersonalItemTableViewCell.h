//
//  LWPersonalItemTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kPersonalItemTableViewCell           @"LWPersonalItemTableViewCell"
#define kPersonalItemTableViewCellIdentifier @"LWPersonalItemTableViewCellIdentifier"


@interface LWPersonalItemTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
