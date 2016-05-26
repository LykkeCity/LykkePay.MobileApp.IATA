#import "SCHStockRenderer.h"


@class SCHAbstractPoint;
@class SCHSeriesPaintInfo;


@interface SCHBarStockRenderer : SCHStockRenderer

- (void)drawPoint:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)pinfo
               X1:(CGFloat)x1 X2:(CGFloat)x2 Point:(SCHAbstractPoint *)p;

@end
