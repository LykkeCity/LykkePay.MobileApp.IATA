#import <Foundation/Foundation.h>

#import "SCHAppearance.h"
#import "SCHPaint.h"


@interface SCHPaintUtils : NSObject

+ (void)drawBitmap:(CGContextRef)c Paint:(SCHPaint *)p Bitmap:(UIImage *)b
                 X:(CGFloat)x Y:(CGFloat)y;

+ (void)drawLine:(CGContextRef)c Paint:(SCHPaint *)p
      Appearance:(SCHAppearance *)a
           FromX:(CGFloat)fromX FromY:(CGFloat)fromY
             ToX:(CGFloat)toX ToY:(CGFloat)toY;

+ (void)drawLine:(CGContextRef)c Paint:(SCHPaint *)p
      Appearance:(SCHAppearance *)a From:(CGPoint)from To:(CGPoint)to;

+ (void)fillRect:(CGContextRef)c Paint:(SCHPaint *)p
      Appearance:(SCHAppearance *)a Rect:(CGRect)r;

+ (void)drawRect:(CGContextRef)c Paint:(SCHPaint *)p
      Appearance:(SCHAppearance *)a Rect:(CGRect)r;

+ (void)drawCircle:(CGContextRef)c Paint:(SCHPaint *)p
        Appearance:(SCHAppearance *)a X:(CGFloat)x Y:(CGFloat)y
                 R:(CGFloat)r;

+ (void)drawSquare:(CGContextRef)c Paint:(SCHPaint *)p
        Appearance:(SCHAppearance *)a X:(CGFloat)x Y:(CGFloat)y
                 R:(CGFloat)r;

+ (void)drawFullRect:(CGContextRef)c Paint:(SCHPaint *)p
          Appearance:(SCHAppearance *)a Rect:(CGRect)r;

+ (NSDictionary *)getTextAttributesForPaint:(SCHPaint *)p;

+ (void)drawText:(CGContextRef)c Paint:(SCHPaint *)p
      Appearance:(SCHAppearance *)a Text:(NSString *)t At:(CGPoint)pos;

+ (CGFloat)getScaleFactor;

@end
