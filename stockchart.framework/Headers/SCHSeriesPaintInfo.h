#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class SCHPaintInfo;
@class SCHAxis;

@interface SCHSeriesPaintInfo : NSObject

+ (CGFloat)getCoordinate:(CGFloat)value Min:(CGFloat)min
                    Factor:(CGFloat)factor;

@property SCHPaintInfo *paintInfoX;

@property SCHPaintInfo *paintInfoY;

- (instancetype)init;

- (CGFloat)getX:(CGFloat)value;

- (CGFloat)getY:(CGFloat)value;

- (void)loadFromAxisX:(SCHAxis *)xAxis AxisY:(SCHAxis *)yAxis;

- (void)reset;

@end
