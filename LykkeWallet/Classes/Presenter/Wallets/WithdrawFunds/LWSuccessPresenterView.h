//
//  LWSuccessPresenterView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 15/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWSuccessPresenterView : UIView

-(id) initWithFrame:(CGRect)frame title:(NSString *) title text:(NSString *) text;

@property id delegate;

@end


@protocol LWSuccessPresenterViewDelegate


-(void) successPresenterViewPressedReturn:(LWSuccessPresenterView *) view;

@end