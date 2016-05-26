#import "SCHAxis.h"

#import <Foundation/Foundation.h>


@class SCHAbstractPoint;
@class SCHAbstractRenderer;
@class SCHSeriesPaintInfo;


@protocol SCHSeriesPointAdapter <NSObject>

- (NSInteger)getPointCount;

- (SCHAbstractPoint *)getPointAt:(NSInteger)i;

@end


@interface SCHSeries : NSObject

@property SCHAxisSide xAxisSide;

@property SCHAxisSide yAxisSide;

@property NSInteger xAxisVirtualId;

@property NSInteger yAxisVirtualId;

@property NSInteger indexOffset;

@property (getter=isVisible) BOOL visible;

@property CGFloat lastValue;

@property NSString *name;

@property id<SCHSeriesPointAdapter> pointAdapter;

@property SCHAbstractRenderer *renderer;

@property NSString *areaName;

- (instancetype)init;

- (instancetype)initWithAreaName:(NSString *)areaName
                        Renderer:(SCHAbstractRenderer *)renderer;

- (CGFloat)getPointValueAt:(NSInteger)i ValueIndex:(NSInteger)valueIndex;

- (NSArray *)getMaxMinPriceWithViewMax:(CGFloat)viewMax
                               ViewMin:(CGFloat)viewMin;

- (NSArray *)getMaxMinPriceWithStartIndex:(NSInteger)startIndex
                                 EndIndex:(NSInteger)endIndex;

- (SCHAbstractPoint *)getPointAtValue:(CGFloat)value;

- (SCHAbstractPoint *)getFirstPoint;

- (SCHAbstractPoint *)getLastPoint;

- (NSInteger)convertToArrayIndexZeroBased:(CGFloat)value;

- (NSInteger)convertToArrayIndex:(CGFloat)value;

- (CGFloat)convertToScaleIndex:(NSInteger)indexInArray;

- (BOOL)hasPoints;

- (CGFloat)getLastScaleIndex;

- (CGFloat)getFirstScaleIndex;

- (BOOL)isVisibleOnScreenWithViewMax:(CGFloat)viewMax ViewMin:(CGFloat)viewMin;

- (SCHAbstractPoint *)getPointAt:(NSInteger)i;

- (void)draw:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)pinfo;

- (NSInteger)getPointCount;

@end
