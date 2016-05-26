#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class SCHAbstractPoint;
@class SCHAppearance;
@class SCHSeriesPaintInfo;


@interface SCHAbstractRenderer : NSObject

@property (readonly) SCHAppearance *appearance;

- (instancetype)init;

- (void)preDraw:(CGContextRef)c;

- (void)postDraw:(CGContextRef)c;

- (void)drawPoint:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)pinfo
               X1:(CGFloat)x1 X2:(CGFloat)x2 Point:(SCHAbstractPoint *)p;

@end
