#import <Foundation/Foundation.h>
#import "SCHAxis.h"


@class SCHAppearance;
@class SCHSeriesPaintInfo;


@interface SCHAbstractSticker : NSObject

@property NSInteger radius;

@property (readonly) SCHAppearance *appearance;

@property (readonly) SCHAppearance *guideLineAppearance;

@property (readonly) CGFloat x1;

@property (readonly) CGFloat x2;

@property (readonly) CGFloat y1;

@property (readonly) CGFloat y2;

@property SCHAxisSide horizontalAxis;

@property SCHAxisSide verticalAxis;

@property NSString *areaName;

@property BOOL drawGuideLine;

@property (getter=isLocked) BOOL locked;

- (instancetype)init;

- (instancetype)initWithAreaName:(NSString *)areaName;

- (BOOL)isValid;

- (void)reset;

- (CGFloat)getMidX;

- (CGFloat)getMidY;

- (void)setFirstPointX:(CGFloat)x Y:(CGFloat)y;

- (void)setSecondPointX:(CGFloat)x Y:(CGFloat)y;

- (void)draw:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)info;


- (void)draw:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)info
      Point1:(CGPoint)p1 Point2:(CGPoint)p2;

@end
