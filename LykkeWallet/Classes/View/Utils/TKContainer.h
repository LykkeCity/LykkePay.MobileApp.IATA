//
//  TKContainer.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 02.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKView.h"


@interface TKContainer : UIView {
    
}

@property (readonly, nonatomic) TKView *contentView;


#pragma mark - Common

- (void)attach:(TKView *)view;

@end
