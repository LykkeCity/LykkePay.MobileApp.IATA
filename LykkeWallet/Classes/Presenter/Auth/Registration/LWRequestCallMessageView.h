//
//  LWRequestcallMessageView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWRequestCallMessageView : UIView

-(void) showWithCompletion:(void(^)(void)) completion;

@end

