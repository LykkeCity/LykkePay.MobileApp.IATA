#import "SCHStockChartView.h"

#import "SCHGlyphList.h"
#import "SCHStickerList.h"


@class SCHAbstractSticker;
@class SCHIndicatorManager;


extern SCHCustomObjectKey SCHCustomObjectStickerListID;
extern SCHCustomObjectKey SCHCustomObjectStickerInfoID;
extern SCHCustomObjectKey SCHCustomObjectGlyphListID;

extern const NSInteger kSCHStockChartViewHitTestStickers;

extern const NSInteger kSCHStockChartViewEventStickerAdded;


@interface SCHStockChartViewPro : SCHStockChartView

@property (readonly) SCHStickerList *stickers;

@property (readonly) SCHGlyphList *glyphs;

@property (readonly) SCHIndicatorManager *indicatorManager;

- (void)cancelSticker;

- (void)getHitTestInfo:(SCHStockChartViewHitTestInfo *)info
                     X:(NSInteger)x Y:(NSInteger)y R:(NSInteger)r
               Options:(NSInteger)options;

- (void)letTheUserGlueSticker:(SCHAbstractSticker *)s;

- (void)reset;

@end
