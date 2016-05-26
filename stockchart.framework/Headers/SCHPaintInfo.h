#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class SCHAxis;


@interface SCHPaintInfo : NSObject

+ (CGFloat)getCoordinate:(CGFloat)value Min:(CGFloat)min
                  Factor:(CGFloat)factor;

@property CGFloat max;

@property CGFloat min;

@property (getter=isHorizontal) BOOL horizontal;

@property (getter=isLogarithmic) BOOL logarithmic;

@property CGFloat size;

- (instancetype)init;

- (CGFloat)get:(CGFloat)value;

- (void)loadFrom:(SCHAxis *)axis;

@end
