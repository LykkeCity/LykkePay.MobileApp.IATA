//
//  LWBaseHistoryPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@interface LWBaseHistoryPresenter : LWAuthComplexPresenter {
    
}


#pragma mark - Properties

@property (copy,   nonatomic) NSString *assetId;
@property (assign, nonatomic) BOOL shouldGoBack;

@end
