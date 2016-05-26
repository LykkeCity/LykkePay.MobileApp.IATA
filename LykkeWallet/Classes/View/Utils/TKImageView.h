//
//  TKImageView.h
//  LykkeWallet
//
//  Created by Георгий Малюков on 03.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "TKView.h"

typedef UIImage *(^TKImageViewLoadingBlock)();


@interface TKImageView : TKView {
    
}

@property (copy, nonatomic) TKImageViewLoadingBlock loadingBlock;

@end
