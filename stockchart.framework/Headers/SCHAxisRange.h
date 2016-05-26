#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ENUM(NSInteger, SCHAxisRangeViewValues)
{
    SCHAxisRangeViewValuesFitScreen,
    SCHAxisRangeViewValuesScrollToLast,
    SCHAxisRangeViewValuesScrollToFirst
};


@class SCHAxisRange;
@protocol SCHAxisRangeEventListener <NSObject>

- (void)onMoveViewValues:(SCHAxisRange *)sender OldMinValue:(CGFloat)oldMin
             OldMaxValue:(CGFloat)oldMax NewMinValue:(CGFloat)newMin
             NewMaxValue:(CGFloat)newMax;

- (void)onZoomViewValues:(SCHAxisRange *)sender OldMinValue:(CGFloat)oldMin
             OldMaxValue:(CGFloat)oldMax NewMinValue:(CGFloat)newMin
             NewMaxValue:(CGFloat)newMax;

@end


@interface SCHAxisRange : NSObject

@property (getter=isAutoValue) BOOL autoValue;

@property CGFloat minValue;

@property CGFloat maxValue;

@property (getter=isZoomable) BOOL zoomable;

@property (getter=isMoveable) BOOL moveable;

@property CGFloat margin;

@property CGFloat minViewLength;

@property CGFloat maxViewLength;

@property (weak) id<SCHAxisRangeEventListener> eventListener;

@property (readonly) CGFloat length;

@property (readonly) CGFloat viewLength;

- (instancetype)init;

- (void)expandAutoValuesMax:(CGFloat)max Min:(CGFloat)min;

- (void)expandValuesMax:(CGFloat)max Min:(CGFloat)min;

- (BOOL)expandViewValuesMax:(CGFloat)max Min:(CGFloat)min;

- (CGFloat)getMarginMax:(CGFloat)max Min:(CGFloat)min;

- (CGFloat)getMaxOrAutoValue;

- (CGFloat)getMaxViewValueOrAutoValue;

- (CGFloat)getMinOrAutoValue;

- (CGFloat)getMinViewValueOrAutoValue;

- (void)moveViewValues:(CGFloat)factor;

- (void)resetAutoValues;

- (void)resetViewValues;

- (BOOL)setViewValuesMax:(CGFloat)max Min:(CGFloat)min;

- (BOOL)setViewValues:(enum SCHAxisRangeViewValues)vw
             ViewSize:(CGFloat)viewSize;

- (BOOL)setViewValues:(enum SCHAxisRangeViewValues)vw;

- (void)zoomViewValues:(CGFloat)factor;

@end
