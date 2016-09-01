//
//  LWBaseHistoryPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"

@class LWEmptyHistoryPresenter;

@interface LWBaseHistoryPresenter : LWAuthComplexPresenter {
    
}


@property (strong, nonatomic) LWEmptyHistoryPresenter *emptyHistoryPresenter;

#pragma mark - Properties

@property (copy,   nonatomic) NSString *assetId;
@property (assign, nonatomic) BOOL shouldGoBack;

@property (readonly, nonatomic) NSArray *operations;




@end
