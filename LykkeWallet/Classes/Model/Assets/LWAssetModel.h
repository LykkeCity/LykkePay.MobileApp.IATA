//
//  LWAssetModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 02.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWAssetModel : LWJSONObject {
    
}


#pragma mark - Properties

@property (readonly, nonatomic) NSString *identity;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *symbol;
@property (readonly, nonatomic) NSNumber *accuracy;
@property (readonly) BOOL hideDeposit;
@property (readonly) BOOL hideWithdraw;


#pragma mark - Root

+ (NSString *)assetByIdentity:(NSString *)identity fromList:(NSArray *)list;

@end
