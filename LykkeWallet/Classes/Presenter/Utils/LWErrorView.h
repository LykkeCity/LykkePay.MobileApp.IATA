//
//  LWErrorView.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LWErrorView : UIView


#pragma mark - General

+ (LWErrorView *)modalViewWithDescription:(NSString *)description;

@end
