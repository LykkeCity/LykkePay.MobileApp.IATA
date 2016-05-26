#import <UIKit/UIKit.h>

#import "SCHArea.h"
#import "SCHAreaList.h"
#import "SCHLineList.h"
#import "SCHSeriesList.h"


@class SCHChartElement;
@class SCHCrosshair;
@class SCHLine;
@class SCHSeries;
@class SCHStickerInfo;


typedef id<NSCopying> SCHCustomObjectKey;

extern SCHCustomObjectKey SCHCustomObjectCrosshairID;
extern SCHCustomObjectKey SCHCustomObjectSeriesListID;
extern SCHCustomObjectKey SCHCustomObjectLineListID;

extern const NSInteger kSCHStockChartViewHitTestShallow;
extern const NSInteger kSCHStockChartViewHitTestDeep;
extern const NSInteger kSCHStockChartViewHitTestSeries;


typedef NS_ENUM(NSInteger, SCHStockChartViewState)
{
    SCHStockChartViewStateIdle,
    SCHStockChartViewStateBeginMove,
    SCHStockChartViewStateBeginZoom,
    SCHStockChartViewStateMoving,
    SCHStockChartViewStateZooming
};


@protocol SCHStockChartViewEventHandler <NSObject>

- (void)onChartEvent:(NSInteger)what Object:(id)object;

@end


@interface SCHStockChartViewHitTestInfo : NSObject

@property SCHChartElement *element;

@property NSMutableDictionary *points;

@property NSObject *object;

- (SCHPlot *)elementAsPlot;

- (void)reset;

@end


@interface SCHStockChartView : UIView <UIGestureRecognizerDelegate>

@property UIColor *clearColor;

@property (readonly) SCHCrosshair *crosshair;

@property (readonly) SCHAreaList *areas;

@property (readonly) SCHLineList *lines;

@property (readonly) SCHStockChartViewState state;

@property (readonly) SCHSeriesList *series;

@property id<SCHStockChartViewEventHandler> chartEventHandler;

+ (SCHCustomObjectKey)createObjectID;

- (SCHLine *)addLine:(SCHArea *)a Side:(SCHAxisSide)side Value:(CGFloat)value;

- (BOOL)hasSeries:(NSString *)areaName;

- (SCHSeriesList *)getSeriesAt:(NSString *)areaName;

- (SCHSeries *)addSeries:(SCHArea *)a;

- (SCHArea *)addArea;

- (SCHArea *)findAreaBySeriesName:(NSString *)seriesName;

- (SCHArea *)findAreaByName:(NSString *)name;

- (SCHSeries *)findSeriesByName:(NSString *)name;

- (void)disableGlobalAxisRange:(SCHAxisSide)side;

- (void)enableGlobalAxisRange:(SCHAxisRange *)range forSide:(SCHAxisSide)side;

- (SCHAxisRange *)getGlobalAxisRange:(SCHAxisSide)side;

- (void)getHitTestInfo:(SCHStockChartViewHitTestInfo *)info
                     X:(NSInteger)x Y:(NSInteger)y R:(NSInteger)r
               Options:(NSInteger)options;

- (SCHStockChartViewHitTestInfo *)getHitTestInfoWithX:(NSInteger)x
                                                    Y:(NSInteger)y
                                                    R:(NSInteger)r;

- (SCHStockChartViewHitTestInfo *)getHitTestInfoWithX:(NSInteger)x
                                                    Y:(NSInteger)y
                                                    R:(NSInteger)r
                                              Options:(NSInteger)options;

- (BOOL)processCrosshairAtX:(CGFloat)x Y:(CGFloat)y R:(CGFloat)r;

- (void)recalc;

- (void)reset;

- (void)resetPositions;

- (void)resetView;

@end
