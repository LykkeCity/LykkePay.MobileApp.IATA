//
//  LWBackupCheckWordsPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupTemplatePresenterViewController.h"
#import "LWPrivateKeyManager.h"

@interface LWBackupCheckWordsPresenter : LWBackupTemplatePresenterViewController

@property (strong, nonatomic) NSArray *wordsList;

@property BACKUP_MODE backupMode;

@end
