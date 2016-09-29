//
//  LWBackupNotificationView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 29/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {BackupRequestTypeOptional, BackupRequestTypeRequired} BackupRequestType;

@interface LWBackupNotificationView : UIView

-(void) show;

@property (strong, nonatomic) NSString *text;
@property BackupRequestType type;


@end

