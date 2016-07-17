//
//  LWBackupMessageView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 16/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWBackupMessageView : UIView

-(void) showWithCompletion:(void(^)(BOOL result)) completion;

@end

