//
//  LWPKBackupPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 28/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWPKBackupModel.h"

typedef enum {BackupViewTypePassword, BackupViewTypeHint} BackupViewType;

@interface LWPKBackupPresenter : LWAuthComplexPresenter

@property BackupViewType type;
@property (strong, nonatomic) LWPKBackupModel *backupModel;

@end
