//
//  LWAssetCategoryModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 27/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetCategoryModel.h"

@implementation LWAssetCategoryModel

-(id) initWithDictionary:(NSDictionary *) dict
{
    self=[super init];
    
    _name=dict[@"Name"];
    _sortOrder=[dict[@"SortOrder"] intValue];
    _iconUrl=dict[@"IosIconUrl"];
    _identity=dict[@"Id"];
    
    
    return self;
}

@end
