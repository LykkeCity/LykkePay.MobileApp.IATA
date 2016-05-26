//
//  LWTransferTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 09.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kTransferTableViewCell           @"LWTransferTableViewCell"
#define kTransferTableViewCellIdentifier @"LWTransferTableViewCellIdentifier"


@interface LWTransferTableViewCell : TKTableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *recipientImageView;
@property (weak, nonatomic) IBOutlet UILabel     *recipientLabel;

@end
