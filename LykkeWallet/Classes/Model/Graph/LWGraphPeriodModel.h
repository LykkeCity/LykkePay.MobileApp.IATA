//
//  LWGraphPeriodModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWGraphPeriodModel : LWJSONObject<NSCopying> {
    
}


#pragma mark - Properties

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *value;

@end
