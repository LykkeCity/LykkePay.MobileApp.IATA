//
//  LWPrivateWalletAssetModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPrivateWalletAssetModel : NSObject

@property (strong, nonatomic) NSString *assetId;
@property (strong, nonatomic) NSNumber *baseAssetAmount;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *name;


@end
