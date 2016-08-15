//
//  LWPKTransferConfirmationCellView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 08/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPKTransferConfirmationCellView : UITableViewCell

@property (strong, nonatomic) NSString *leftText;
@property (strong, nonatomic) NSString *rightText;

-(CGFloat) heightForWidth:(CGFloat) width;


@end
