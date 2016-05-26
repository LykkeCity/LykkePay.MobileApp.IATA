#import <Foundation/Foundation.h>

#import "SCHGridPainter.h"
#import "SCHChartElement.h"
#import "SCHAppearance.h"
#import "SCHAxisRange.h"
#import "SCHPaintInfo.h"


typedef NS_ENUM(NSInteger, SCHAxisSide)
{
    SCHAxisSideLeft,
    SCHAxisSideRight,
    SCHAxisSideTop,
    SCHAxisSideBottom,
    SCHAxisSideUnknown
};


@class SCHArea;
@class SCHAxis;
@class SCHPaintInfo;


@protocol SCHAxisLabelFormatProvider <NSObject>

- (NSString *)getAxisLabel:(SCHAxis *)axis Value:(CGFloat)value;

@end


@protocol SCHAxisScaleValuesProvider <NSObject>

- (NSArray *)getScaleValues:(SCHPaintInfo *)info Count:(NSInteger)valuesCount;

@end


@interface SCHAxis : SCHChartElement <SCHGridPainterGridLabelsProvider>

@property (readonly) SCHAxisSide side;

@property CGFloat sizeInPixels;

@property CGFloat invisibleSizeInPixels;

@property (getter=isVisible) BOOL visible;

@property BOOL drawLastValue;

@property BOOL drawLineValues;

@property BOOL drawMaxMin;

@property  NSInteger linesCount;

@property (readonly) SCHAppearance *appearance;

@property SCHAxisRange *axisRange;

@property SCHAxisRange *globalAxisRange;

@property id<SCHAxisLabelFormatProvider> labelFormatProvider;

@property id<SCHAxisScaleValuesProvider> scaleValuesProvider;

@property (readonly) SCHArea *parentArea;

@property (getter=isLogarithmic) BOOL logarithmic;

@property NSNumberFormatter *decimalFormat;

+ (BOOL)isHorizontal:(enum SCHAxisSide)side;

+ (BOOL)isVertical:(enum SCHAxisSide)side;

- (instancetype)initWithParent:(SCHChartElement *)parent
                          Side:(SCHAxisSide)side;

- (SCHAxisRange *)getAxisRangeOrGlobalAxisRange;

- (CGFloat)getCoordinate:(CGFloat)value;

- (NSString *)getLabel:(CGFloat)value;

- (NSArray *)getScaleValues:(SCHPaintInfo *)pinfo;

- (CGFloat)getSizeOrInvisibleSizeInPixels;

- (CGFloat)getValueByCoordinate:(CGFloat)coord Absolute:(BOOL)isAbsolute;

- (BOOL)isHorizontal;

- (BOOL)isVertical;

@end