#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#import "SCHPaint.h"


typedef NS_ENUM(NSInteger, SCHAppearanceGradient)
{
    SCHAppearanceGradientNone,
    SCHAppearanceGradientLinearHorizontal,
    SCHAppearanceGradientLinearVertical
};

typedef NS_ENUM(NSInteger, SCHAppearanceOutlineStyle)
{
    SCHAppearanceOutlineStyleSolid,
    SCHAppearanceOutlineStyleDash
};

typedef NS_ENUM(NSInteger, SCHAppearanceFontStyle)
{
    SCHAppearanceFontStyleBold,
    SCHAppearanceFontStyleItalic,
    SCHAppearanceFontStyleBoldItalic,
    SCHAppearanceFontStyleNormal
};


@interface SCHAppearanceFont : NSObject

@property (readonly) NSString *familyName;

@property (readonly) SCHAppearanceFontStyle fontStyle;

@property (readonly) UIFontDescriptor *fontDescriptor;

@property UIColor *color;

@property CGFloat fontSize;

- (instancetype)init;

- (instancetype)initWithFamilyName:(NSString *)name
                             Style:(SCHAppearanceFontStyle)style;

- (void)fill:(SCHAppearanceFont *)f;

- (void)fromFamilyName:(NSString *)name Style:(SCHAppearanceFontStyle)style;

- (void)reloadFontDescriptor;

@end


@interface SCHAppearance : NSObject

@property UIColor *primaryFillColor;

@property UIColor *secondaryFillColor;

@property SCHAppearanceGradient gradient;

@property CGFloat outlineWidth;

@property BOOL pixelPerfect;

@property UIColor *outlineColor;

@property SCHAppearanceOutlineStyle outlineStyle;

@property (getter=isAntialiased) BOOL antialiased;

@property (readonly) SCHAppearanceFont *font;

- (instancetype)init;

+ (UIFontDescriptorSymbolicTraits)fontStyleToSymbolicTraits:(SCHAppearanceFontStyle)fs;

- (void)applyFill:(SCHPaint *)p Rect:(CGRect)rect;

- (void)applyOutline:(SCHPaint *)p;

- (void)applyText:(SCHPaint *)p;

- (CGSize)measureTextSize:(NSString *)text Paint:(SCHPaint *)p
                ApplyText:(BOOL)applyText;

- (void)setAllColors:(UIColor *)color;

@end
