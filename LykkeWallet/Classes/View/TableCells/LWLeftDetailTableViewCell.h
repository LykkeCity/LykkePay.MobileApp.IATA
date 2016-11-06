//
//  LWLeftDetailTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kLeftDetailTableViewCell           @"LWLeftDetailTableViewCell"
#define kLeftDetailTableViewCellIdentifier @"LWLeftDetailTableViewCellIdentifier"
#define kLeftDetailTableViewCellHeight     50


@interface LWLeftDetailTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
