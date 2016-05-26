//
//  LWReceiverPresenter.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.04.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@interface LWReceiverPresenter : LWAuthComplexPresenter {
    
}

#pragma mark - Properties

@property (copy, nonatomic) NSString *recepientId;
@property (copy, nonatomic) NSString *recepientName;
@property (copy, nonatomic) NSString *recepientImage;
@property (copy, nonatomic) NSString *selectedAssetId;

@end
