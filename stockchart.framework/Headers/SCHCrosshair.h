#import <Foundation/Foundation.h>

#import "SCHAxis.h"


@class SCHCrosshair;
@class SCHPlot;
@class SCHAppearance;


@protocol SCHCrosshairLabelFormatProvider <NSObject>

- (NSString *)getLabel:(SCHCrosshair *)sender Plot:(SCHPlot *)plot
                     X:(CGFloat)x Y:(CGFloat)y;

@end


@interface SCHCrosshair : NSObject

@property (readonly) SCHAppearance *appearance;

@property (getter=isAutomatic) BOOL automatic;

@property (getter=isVisible) BOOL visible;

@property BOOL drawHorizontal;

@property BOOL drawVertical;

@property CGFloat xValue;

@property CGFloat yValue;

@property SCHAxisSide horizontalAxis;

@property SCHAxisSide verticalAxis;

@property id<SCHCrosshairLabelFormatProvider> labelFormatProvider;

@property SCHPlot *parent;

- (instancetype)init;

- (void)draw:(CGContextRef)c Plot:(SCHPlot *)plot ClipRect:(CGRect)clipRect;

@end
