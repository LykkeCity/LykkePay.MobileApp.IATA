#import <Foundation/Foundation.h>

#import "SCHPaint.h"
#import "SCHCustomObjects.h"


@interface SCHChartElement : NSObject

@property (readonly) SCHPaint *paint;

@property (readonly) SCHChartElement *parent;

@property (readonly) CGFloat height;

@property (readonly) CGFloat width;

- (instancetype)initWithParent:(SCHChartElement *)parent;

- (void)draw:(CGContextRef)c WithObjects:(SCHCustomObjects *)customObjects;

- (void)drawSimple:(CGContextRef)c;

- (CGRect)getAbsoluteBounds;

- (CGPoint)getAbsolutePositionWithX:(CGFloat)x Y:(CGFloat)y;

- (CGRect)getBounds;

- (CGRect)getRelativeBounds;

- (CGPoint)getRelativePositionWithX:(CGFloat)x Y:(CGFloat)y;

- (void)setBoundsWithRelX:(CGFloat)relX RelY:(CGFloat)relY
                        W:(CGFloat)w H:(CGFloat)h;

- (void)setBounds:(CGRect)r;


@end
