//
//  LWPushNotificationView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPushNotificationView : UIView

+(void) showPushNotification:(NSDictionary *) pushDict clickImmediately:(BOOL) flagClick;

@end
