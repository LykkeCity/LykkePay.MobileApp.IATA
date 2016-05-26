#import "SCHAbstractRenderer.h"


@class SCHAppearance;


@interface SCHStockRenderer : SCHAbstractRenderer

@property (readonly) SCHAppearance *fallAppearance;

@property (readonly) SCHAppearance *riseAppearance;

@property (readonly) SCHAppearance *neutralAppearance;

- (instancetype)init;

@end
