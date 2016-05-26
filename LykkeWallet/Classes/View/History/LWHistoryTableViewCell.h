//
//  LWHistoryTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"


#define kHistoryTableViewCell           @"LWHistoryTableViewCell"
#define kHistoryTableViewCellIdentifier @"LWHistoryTableViewCellIdentifier"


@interface LWHistoryTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIImageView *operationImageView;
@property (weak, nonatomic) IBOutlet UILabel     *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel     *valueLabel;

@end
