//
//  LWCameraMessageView2.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 01/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWCameraMessageView2 : UIView

-(void) showWithCompletion:(void(^)(BOOL result)) completion;

@end

