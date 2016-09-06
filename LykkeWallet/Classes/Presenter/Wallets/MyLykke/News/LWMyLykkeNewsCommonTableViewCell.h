//
//  LWMyLykkeNewsCommonTableViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 31/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWNewsElementModel;

@interface LWMyLykkeNewsCommonTableViewCell : UITableViewCell

@property (strong, nonatomic) LWNewsElementModel *element;
@property (strong, nonatomic) LWNewsElementModel *element2;

@property (strong, nonatomic) LWNewsElementModel *element3;

-(void) hideEmpty;

@property id delegate;


@end


@protocol  LWNewsTableViewCellDelegate


-(void) newsCellPressedElement:(LWNewsElementModel *) element;

@end