#import <Foundation/Foundation.h>


@class SCHSeries;

typedef NSMutableDictionary SCHIndicatorData;

typedef NSMutableArray SCHIndicatorDataValues;


NSInteger schIndicatorDataValuesCalcIndexOffset(SCHIndicatorDataValues *values,
                                                SCHSeries *src);

SCHIndicatorData *schIndicatorDataCreate(NSInteger i, SCHIndicatorDataValues *v);
