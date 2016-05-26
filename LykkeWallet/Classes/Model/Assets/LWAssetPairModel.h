//
//  LWAssetPairModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetPairModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *group;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSNumber *accuracy;
@property (readonly, nonatomic) NSString *baseAssetId;
@property (readonly, nonatomic) NSString *quotingAssetId;

@end
