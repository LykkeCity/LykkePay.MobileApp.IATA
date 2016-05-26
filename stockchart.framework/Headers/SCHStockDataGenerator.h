#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SCHStockDataPoint : NSObject

@property NSDate *dt;

@property CGFloat o;

@property CGFloat h;

@property CGFloat l;

@property CGFloat c;

@property CGFloat v;

@end


@interface SCHStockDataGenerator : NSObject

@property CGFloat volatility;

@property CGFloat startPrice;

@property CGFloat lastPrice;

@property CGFloat maxVolume;

- (SCHStockDataPoint *)getNextPoint;

- (NSArray *)getNext:(NSInteger)count;

- (instancetype)init;

- (instancetype)initWithVolatility:(CGFloat)volatility
                        startPrice:(CGFloat)startPrice
                         maxVolume:(CGFloat)maxVolume;

@end