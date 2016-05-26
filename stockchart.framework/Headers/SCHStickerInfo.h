#import <Foundation/Foundation.h>


@class SCHAbstractSticker;
@class SCHArea;


@interface SCHStickerInfo : NSObject

@property SCHAbstractSticker *sticker;

@property NSInteger stickerPoint;

@property SCHArea *area;

- (instancetype)initWithArea:(SCHArea *)a Sticker:(SCHAbstractSticker *)s;

@end
