//
//  LWBackupSingleWordPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupTemplatePresenterViewController.h"

@interface LWBackupSingleWordPresenter : LWBackupTemplatePresenterViewController

@property (strong, nonatomic) NSArray *wordsList;
@property int currentWordNum;

@end
