#import <Foundation/Foundation.h>

#import "SCHChartElement.h"
#import "SCHAppearance.h"
#import "SCHAxis.h"


typedef NSUInteger SCHAreaAxisId;
typedef BOOL (^SCHAreaAxisAction)(SCHAreaAxisId axisId, SCHAxis *a);


@class SCHPlot;
@class SCHLegend;
@class SCHSeries;


@interface SCHArea : SCHChartElement

@property SCHAppearance *areaAppearance;

@property enum SCHAxisSide verticalGridAxisSide;

@property enum SCHAxisSide horizontalGridAxisSide;

@property (getter=isVerticalGridVisible) BOOL verticalGridVisible;

@property (getter=isHorizontalGridVisible) BOOL horizontalGridVisible;

@property (getter=isAutoHeight) BOOL autoHeight;

@property CGFloat heightInPercents;

@property NSString *title;

@property NSString *name;

@property CGFloat globalLeftMargin;

@property CGFloat globalRightMargin;

@property (getter=isVisible) BOOL visible;

@property (readonly) SCHPlot *plot;

@property (readonly) SCHLegend *legend;

- (instancetype)init;

- (SCHAreaAxisId)addVirtualAxis:(SCHAxisSide)side;

- (void)doAxisAction:(SCHAreaAxisAction)a;

- (NSArray *)getAxes;

- (SCHAxis *)getAxis:(enum SCHAxisSide)side;

- (SCHAxis *)getAxis:(enum SCHAxisSide)side AxisId:(SCHAreaAxisId)axisId;

- (SCHAxis *)getBottomAxis;

- (SCHAxis *)getLeftAxis;

- (SCHAxis *)getRightAxis;

- (SCHAxis *)getTopAxis;

- (NSInteger)getCoordinate:(SCHAxisSide)side Value:(CGFloat)value;

- (SCHAxis *)getVerticalGridAxis;

- (SCHAxis *)getHorizontalGridAxis;

- (SCHAxis *)getVirtualAxis:(SCHAreaAxisId)axisId;

- (CGRect)getSideMargins;

- (CGFloat)getValueByCoordinate:(SCHAxisSide)side
                     Coordinate:(NSInteger)coordinate
                       Absolute:(BOOL)isAbsolute;

- (void)moveWithFactorH:(CGFloat)hFactor V:(CGFloat)vFactor;

- (void)removeVirtualAxis:(SCHAreaAxisId)axisId;

- (void)setAllAxesVisible:(BOOL)value;

- (void)setAxesVisibleLeft:(BOOL)left Top:(BOOL)top
                     Right:(BOOL)right Bottom:(BOOL)bottom;

+ (NSString *)defaultName;

@end
