//
//  LWOrderBookElementModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 09/10/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWOrderBookElementModel.h"

@interface LWOrderBookElementModel()
{
    NSArray *array;
}

@end

@implementation LWOrderBookElementModel

-(id) initWithArray:(NSArray *)arr
{
    self=[super init];
    
    NSMutableArray *newarr=[[NSMutableArray alloc] init];
    
    
//    arr=@[@(10),
//          @(15),
//          @(30),
//          @(100),
//          @(300),
//          @(1000),
//          @(2000),
//          @(10000),
//          @(300000),
//          @(400000),
//          @(1000000),
//          @(2000000)

//          @(10),
//          @(10),
//          @(10),
//          @(10),
//          @(10),
//          ];
    for(NSDictionary *d in arr)
    {
//        [newarr addObject:@{@"Price":@(5.01), @"Volume":d}];
        [newarr addObject:@{@"Price":@([d[@"Price"] doubleValue]), @"Volume":@(fabs([d[@"Volume"] doubleValue]))}];
    }
    array=newarr;
    
    return self;
}

-(void) invert
{
    if(!array.count)
        return;
    NSMutableArray *newarr=[[NSMutableArray alloc] init];
    for(NSDictionary *d in array)
    {
        NSDictionary *dict=@{@"Price":@((double)1.0/[d[@"Price"] doubleValue]), @"Volume":@([d[@"Price"] doubleValue]*[d[@"Volume"] doubleValue])};
        [newarr addObject:dict];
    }
    array=newarr;
}

-(double) priceForVolume:(double)volumeOrig
{
    
    if(!array.count)
        return 0;

    if(volumeOrig==0)
        return [array[0][@"Price"] doubleValue];
    double amount=0;
    double volumeLeft=volumeOrig;
    for(NSDictionary *d in array)
    {
        double price=[d[@"Price"] doubleValue];
        double volume=[d[@"Volume"] doubleValue];
        if(volume<volumeLeft)
        {
            amount+=price*volume;
            volumeLeft-=volume;
        }
        else
        {
            amount+=price*volumeLeft;
            volumeLeft=0;
            break;
        }
    }
    if(volumeLeft>0)
        return amount/(volumeOrig-volumeLeft);
    
    
    return amount/volumeOrig;

}


-(double) priceForResult:(double)volumeOrig
{
    if(!array.count)
        return 0;

    if(volumeOrig==0)
        return [array[0][@"Price"] doubleValue];

    double amount=0;
    double lkkBought=0;
    for(NSDictionary *d in array)
    {
        double price=[d[@"Price"] doubleValue];
        double volume=[d[@"Volume"] doubleValue];
        if(price*volume+amount<volumeOrig)
        {
            amount+=price*volume;
            lkkBought+=volume;
        }
        else
        {
            lkkBought+=(volumeOrig-amount)/price;
            amount=volumeOrig;
            break;
        }
    }
//    if(amount<volumeOrig)
//        return ;
    
    
    return amount/lkkBought;
    
}

-(BOOL) isVolumeOK:(double) volume
{
    double amount=0;
    for(NSDictionary *d in array)
        amount+=[d[@"Volume"] doubleValue];
    return volume<=amount;
}


-(BOOL) isResultOK:(double) result
{
    double amount=0;
    for(NSDictionary *d in array)
        amount+=[d[@"Volume"] doubleValue]*[d[@"Price"] doubleValue];
    return result<=amount;

}


-(LWOrderBookElementModel *) copy
{
    LWOrderBookElementModel *m=[[LWOrderBookElementModel alloc] initWithArray:array];
    return m;
}

-(NSArray *) array
{
    return array;
}


@end
