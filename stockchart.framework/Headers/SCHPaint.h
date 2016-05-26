#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SCHPaintLinearGradient : NSObject

@property UIColor *color1;

@property UIColor *color2;

@property CGPoint point1;

@property CGPoint point2;

+ (instancetype)paintLinearGradientWithColorFirst:(UIColor *)color1
                                      ColorSecond:(UIColor *)color2
                                           Point1:(CGPoint)point1
                                           Point2:(CGPoint)point2;

- (instancetype)initWithColorFirst:(UIColor *)color1
                       ColorSecond:(UIColor *)color2
                            Point1:(CGPoint)point1
                            Point2:(CGPoint)point2;

- (void)drawInContext:(CGContextRef)context;

@end


@interface SCHPaintDashEffect : NSObject

@property NSArray *lengths;

@property CGFloat phase;

+ (instancetype)paintDashEffectNone;

+ (instancetype)paintDashEffectDefaultDash;

+ (instancetype)paintDashEffectWithLengths:(NSArray *)lengths
                                     Phase:(CGFloat)phase;

- (instancetype)initWithLengths:(NSArray *)lengths Phase:(CGFloat)phase;

- (void)applyToContext:(CGContextRef)context;

@end


@interface SCHPaint : NSObject

@property UIColor *strokeColor;

@property UIColor *fillColor;

@property (getter=isAntialiased) BOOL antialiased;

@property CGFloat strokeWidth;

@property CGFloat textSize;

@property UIFontDescriptor *fontDescriptor;

@property SCHPaintDashEffect *dashEffect;

@property SCHPaintLinearGradient *linearGradient;

- (void)reset;

- (void)applyToContext:(CGContextRef)context;

- (CGSize)getTextBounds:(NSString *)text;

@end
