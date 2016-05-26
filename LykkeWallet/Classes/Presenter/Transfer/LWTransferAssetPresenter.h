//
//  LWTransferAssetPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthenticatedTablePresenter.h"


@protocol LWTransferAssetPresenterDelegate <NSObject>

@required
- (void)assetSelected:(NSString *)assetId;

@end


@interface LWTransferAssetPresenter : LWAuthenticatedTablePresenter {
    
}

@property (copy, nonatomic) NSString *selectedAssetId;
@property (weak, nonatomic) id<LWTransferAssetPresenterDelegate> delegate;

@end
