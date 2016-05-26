//
//  TKTableViewCell.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TKTableViewCell : UITableViewCell {
    
}

#pragma mark - Identity

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

@end
