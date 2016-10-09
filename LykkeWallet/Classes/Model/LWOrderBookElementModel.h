//
//  LWOrderBookElementModel.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWOrderBookElementModel : NSObject


-(id) initWithArray:(NSArray *) array;
-(double) priceForVolume:(double) volume;
-(double) priceForResult:(double)volumeOrig;
-(void) invert;

@end
