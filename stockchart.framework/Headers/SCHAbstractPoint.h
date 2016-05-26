#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SCHAbstractPoint : NSObject

@property id pointId;

@property (getter=isVisible) BOOL visible;

@property (readonly) NSMutableArray *values;

- (instancetype)initWithValues:(NSArray *)values;

- (instancetype)initWithCount:(NSUInteger)count;

- (NSArray *)getMaxMin;

- (CGFloat)getValueAt:(NSUInteger)i;

- (void)setValueAt:(NSUInteger)i Value:(CGFloat)v;

- (void)setValuesFrom:(SCHAbstractPoint *)p;

@end
