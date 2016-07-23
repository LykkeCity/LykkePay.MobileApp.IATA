//
//  LWDoubleButtonView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 23/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWDoubleButtonView : UIView

@property id delegate;

-(id) initWithTitles:(NSArray *) titles;

@end
