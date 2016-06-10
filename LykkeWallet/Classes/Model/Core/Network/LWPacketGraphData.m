//
//  LWPacketGraphData.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketGraphData.h"
#import "LWGraphPeriodModel.h"

@implementation LWPacketGraphData

#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
    [super parseResponse:response error:error];
    
    if (self.isRejected) {
        return;
    }
    
    BOOL flagReverted=[response[@"Result"][@"Rate"][@"Inverted"] boolValue];
    
    self.startDate=[self dateFromString:response[@"Result"][@"StartTime"]];
    
    self.endDate=[self dateFromString:response[@"Result"][@"EndTime"]];
    self.fixingTime=[self dateFromString:response[@"Result"][@"FixingTime"]];
    
    self.percentChange=[NSNumber numberWithDouble:[response[@"Result"][@"Rate"][@"PChange"] doubleValue]];
    
    if(flagReverted)
    {
        self.percentChange=[NSNumber numberWithDouble:-[response[@"Result"][@"Rate"][@"PChange"] doubleValue]];

    }
    
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    
    for(NSString *s in response[@"Result"][@"Rate"][@"ChngGrph"])
    {
        if(flagReverted)
            [arr addObject:[NSNumber numberWithDouble:1/[s doubleValue]]];
        else
            [arr addObject:[NSNumber numberWithDouble:[s doubleValue]]];
        
    }
    
    self.graphValues=arr;

}



- (NSString *)urlRelative {
    return @"AssetPairDetailedRates";
}

-(NSDictionary *) params
{
    return @{@"period":self.period.value, @"assetId":self.assetId, @"points":@(20)};
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

-(NSDate *) dateFromString:(NSString *) string
{
    string=[string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    string=[string substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

@end
