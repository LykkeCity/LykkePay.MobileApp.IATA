#import "SCHAbstractRenderer.h"


@class SCHAbstractPoint;
@class SCHSeriesPaintInfo;


typedef NS_ENUM(NSUInteger, SCHLinearRendererPointStyle)
{
    SCHLinearRendererPointStyleSquare,
    SCHLinearRendererPointStyleCircle
};


@interface SCHLinearRenderer : SCHAbstractRenderer

@property CGFloat pointSizeInPercents;

@property (getter=isPointsVisible) BOOL pointsVisible;

@property SCHLinearRendererPointStyle pointStyle;

@property (readonly) SCHAppearance *pointAppearance;

- (instancetype)init;

- (void)preDraw:(CGContextRef)c;

- (void)postDraw:(CGContextRef)c;

- (void)drawPoint:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)pinfo
               X1:(CGFloat)x1 X2:(CGFloat)x2 Point:(SCHAbstractPoint *)p;

@end
