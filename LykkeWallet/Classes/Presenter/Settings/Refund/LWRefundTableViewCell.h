//
//  LWRefundTableViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/06/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {RefundCellTypeInfo, RefundCellTypeAddress, RefundCellTypeAfter} RefundCellType;

@interface LWRefundTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) NSString *addressString;
@property int daysValidAfter;
@property BOOL sendAutomatically;

@property id delegate;

-(id) initWithType:(RefundCellType) type width:(CGFloat) width;

-(void) addDisclosureImage;
-(void) showChangeButton;
-(void) hideChangeButton;

-(void) openAddressCell;

-(CGFloat) height;

@end


@protocol LWRefundTableViewCellDelegate

-(void) addressViewPressedApplyOnCell:(LWRefundTableViewCell *) cell;
-(void) addressCellPressedChange;
-(void) cellTapped:(LWRefundTableViewCell *) cell;

-(void) addressViewPressedScanQRCode:(LWRefundTableViewCell *) cell;

@end
