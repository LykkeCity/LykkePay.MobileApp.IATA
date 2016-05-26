#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SCHIndicatorData.h"
#import "SCHSeries.h"


@class SCHIndicatorConfiguration;


@interface SCHAbstractIndicator : NSObject

@property NSInteger periodsCount;

@property NSInteger valueIndex;

@property (readonly) SCHIndicatorConfiguration *config;

- (instancetype)initWithConfig:(SCHIndicatorConfiguration *)config;

- (SCHIndicatorData *)recalc:(id<SCHSeriesPointAdapter>)src;

@end
