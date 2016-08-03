//
//  LWDropdownView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWDropdownView : UIView

+(void) showWithElements:(NSArray *) elements title:(NSString *) title showDone:(BOOL) showDone showCancel:(BOOL) showCancel activeIndex:(int) index completion:(void(^)(NSInteger)) completion;


@end
