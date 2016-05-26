#import <Foundation/Foundation.h>
#import "SCHAbstractPoint.h"


@interface SCHPoint1 : SCHAbstractPoint

@property CGFloat value;

- (instancetype)init;

- (instancetype)initWithValue:(CGFloat)v;

@end
