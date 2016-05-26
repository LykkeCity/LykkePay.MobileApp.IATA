#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SCHGridPainterGridType)
{
    SCHGridPainterGridTypeHorizontal,
    SCHGridPainterGridTypeVertical
};

typedef NS_ENUM(NSInteger, SCHGridPainterGridLabelPosition)
{
    SCHGridPainterGridLabelPositionIndefinite,
    SCHGridPainterGridLabelPositionNear,
    SCHGridPainterGridLabelPositionFar
};


@protocol SCHGridPainterGridLabelsProvider <NSObject>

- (NSString *)getLabel:(CGFloat)value;

@end

@class SCHPaintInfo;
@class SCHAppearance;
@class SCHPaint;

@interface SCHGridPainter : NSObject

+ (void)drawGridLineAt:(CGFloat)value ClipRect:(CGRect)clipRect
               Context:(CGContextRef)c Appearance:(SCHAppearance *)app
                 Paint:(SCHPaint *)paint PaintInfo:(SCHPaintInfo *)pinfo
                  Type:(SCHGridPainterGridType)gt
              LabelPos:(SCHGridPainterGridLabelPosition)glp
        LabelsProvider:(id<SCHGridPainterGridLabelsProvider>)provider
           LabelLength:(CGFloat)labelLen;

+ (void)drawGridLineAt:(CGFloat)value ClipRect:(CGRect)clipRect
               Context:(CGContextRef)c Appearance:(SCHAppearance *)app
                 Paint:(SCHPaint *)paint PaintInfo:(SCHPaintInfo *)pinfo
                  Type:(SCHGridPainterGridType)gt;

+ (void)drawGrid:(NSArray *)values ClipRect:(CGRect)clipRect
         Context:(CGContextRef)c Appearance:(SCHAppearance *)app
           Paint:(SCHPaint *)paint PaintInfo:(SCHPaintInfo *)pinfo
            Type:(SCHGridPainterGridType)gt
        LabelPos:(SCHGridPainterGridLabelPosition)glp
  LabelsProvider:(id<SCHGridPainterGridLabelsProvider>)provider
     LabelLength:(CGFloat)labelLen;

+ (void)drawGrid:(NSArray *)values ClipRect:(CGRect)clipRect
         Context:(CGContextRef)c Appearance:(SCHAppearance *)app
           Paint:(SCHPaint *)paint PaintInfo:(SCHPaintInfo *)pinfo
            Type:(SCHGridPainterGridType)gt;

@end
