#import <Foundation/Foundation.h>

#import "SCHChartElement.h"


@class SCHSeriesPaintInfo;
@class SCHAppearance;
@class SCHPaintInfo;
@class SCHArea;


@interface SCHPlot : SCHChartElement

@property (readonly) SCHAppearance *plotAppearance;

- (instancetype)initWithParent:(SCHArea *)parent;

- (SCHArea *)getArea;

- (void)drawCustomObjects:(SCHCustomObjects *)customObjects On:(CGContextRef)c;

@end
