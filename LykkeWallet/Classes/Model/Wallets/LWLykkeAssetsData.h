//
//  LWLykkeAssetsData.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWLykkeAssetsData : LWJSONObject {
    
}

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *symbol;
@property (readonly, nonatomic) NSNumber *balance;
@property (readonly, nonatomic) NSString *assetPairId;
@property (readonly, nonatomic) NSString *issuerId;
@property (readonly, assign)    BOOL      hideIfZero;

@end
