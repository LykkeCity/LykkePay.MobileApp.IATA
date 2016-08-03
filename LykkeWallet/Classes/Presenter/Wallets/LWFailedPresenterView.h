//
//  LWFailedPresenterView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWFailedPresenterView : UIView
-(id) initWithFrame:(CGRect)frame title:(NSString *) title text:(NSString *) text;

@property id delegate;

@end


@protocol LWFailedPresenterViewDelegate


-(void) failedPresenterViewPressedReturn:(LWFailedPresenterView *) view;

@end