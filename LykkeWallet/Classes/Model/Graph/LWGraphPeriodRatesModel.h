//
//  LWGraphPeriodRatesModel.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWJSONObject.h"


@interface LWGraphPeriodRatesModel : LWJSONObject<NSCopying> {
    
}


#pragma mark - Properties

@property (copy, nonatomic) NSDate   *fixingTime;
@property (copy, nonatomic) NSDate   *startTime;
@property (copy, nonatomic) NSDate   *endTime;
@property (copy, nonatomic) NSNumber *percantageChange;
// Array of double values
@property (copy, nonatomic) NSArray  *rates;

@end
