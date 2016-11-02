//
//  LWRestoreFromSeedPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 18/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"
#import "LWPrivateKeyManager.h"



@interface LWRestoreFromSeedPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) NSString *email;

@property BACKUP_MODE backupMode;
@property id delegate;

@end

@protocol LWRestoreFromSeedDelegate

-(void) restoreFromSeed:(LWRestoreFromSeedPresenter *) vc restoredKey:(NSString *) keyWif;



@end
