//
//  LWBackupSingleWordPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@interface LWBackupSingleWordPresenter : LWAuthComplexPresenter

@property (strong, nonatomic) NSArray *wordsList;
@property int currentWordNum;

@end
