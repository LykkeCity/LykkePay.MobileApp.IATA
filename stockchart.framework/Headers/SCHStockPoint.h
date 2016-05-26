#import <Foundation/Foundation.h>

#import "SCHPoint4.h"


typedef NS_ENUM(NSInteger, SCHStockPointValue)
{
    SCHStockPointValueHigh,
    SCHStockPointValueLow,
    SCHStockPointValueOpen,
    SCHStockPointValueClose
};

typedef NS_ENUM(NSInteger, SCHStockPointKind)
{
    SCHStockPointKindRise,
    SCHStockPointKindFall,
    SCHStockPointKindNeutral
};


@interface SCHStockPoint : SCHPoint4

@property CGFloat open;

@property CGFloat high;

@property CGFloat low;

@property CGFloat close;

+ (NSInteger)getValueIndex:(enum SCHStockPointValue)pv;

- (instancetype)init;

- (instancetype)initWithOpen:(CGFloat)o High:(CGFloat)h
                         Low:(CGFloat)l Close:(CGFloat)c;

- (SCHStockPointKind)getPointKind;

- (NSArray *)getMaxMin;

- (CGFloat)getValue:(SCHStockPointValue)v;

- (void)setValuesWithOpen:(CGFloat)o High:(CGFloat)h
                      Low:(CGFloat)l Close:(CGFloat)c;

@end
