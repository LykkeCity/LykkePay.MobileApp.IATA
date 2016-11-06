//
//  UIViewController+Loading.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 16.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"


@interface UIViewController (Loading)

- (void)setLoading:(BOOL)loading;
- (MBProgressHUD *)hud;
- (void)showReject:(NSDictionary *)reject response:(NSURLResponse *)response;
- (void)showReject:(NSDictionary *)reject response:(NSURLResponse *)response code:(NSInteger)code willNotify:(BOOL)willNotify;

@end
