//
//  LWBackupGetStartedPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupTemplatePresenterViewController.h"
#import "LWPrivateKeyManager.h"

@interface LWBackupGetStartedPresenter : LWBackupTemplatePresenterViewController

@property BACKUP_MODE backupMode;
@property (strong, nonatomic) NSArray *seedWords;

@end
