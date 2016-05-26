#import "SCHAbstractSticker.h"


@class SCHArea;


@interface SCHSimpleGuideSticker : SCHAbstractSticker

+ (SCHSimpleGuideSticker *)createParallelIn:(SCHArea *)area
                                     Parent:(SCHSimpleGuideSticker *)parent
                                     Offset:(CGFloat)offset;

- (void)draw:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)info
      Point1:(CGPoint)p1 Point2:(CGPoint)p2;

- (SCHSimpleGuideSticker *)createParallelIn:(SCHArea *)area
                                     Offset:(CGFloat)offset;

@end
