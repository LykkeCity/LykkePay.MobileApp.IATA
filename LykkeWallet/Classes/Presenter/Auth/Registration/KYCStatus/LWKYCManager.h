//
//  LWKYCManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface LWKYCManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) UIViewController *viewController;

-(void) manageKYCStatusForAsset:(NSString *)assetId successBlock:(void(^)(void)) completion;

@end
