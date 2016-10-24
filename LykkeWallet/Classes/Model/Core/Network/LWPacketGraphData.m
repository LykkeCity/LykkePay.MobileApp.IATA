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
    
    BOOL flagReverted=[result[@"Rate"][@"Inverted"] boolValue];
    
    self.startDate=[self dateFromString:result[@"StartTime"]];
    
    self.endDate=[self dateFromString:result[@"EndTime"]];
    self.fixingTime=[self dateFromString:result[@"FixingTime"]];
    
    self.percentChange=[NSNumber numberWithDouble:[result[@"Rate"][@"PChange"] doubleValue]];
    self.lastPrice=[NSNumber numberWithFloat:[result[@"LastPrice"] floatValue]];
    
    if(flagReverted)
    {
//        a-старый курс   b-новый курс
//        
//        (b-a)/a=p  —>  b/a - 1 = p —>  a/b = 1 / (p+1)
//        
//        (1/b-1/a)*a=x —> a/b - 1 = x
//        
//        
//        x = 1/(p+1) - 1
        
        
        double ppp=self.percentChange.doubleValue/100;
        self.percentChange=@((1.0/(ppp+1)-1)*100);

        self.lastPrice=@(1/self.lastPrice.doubleValue);
        
    }
    
    
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    
    
    for(NSString *s in result[@"Rate"][@"ChngGrph"])
    {
        NSNumber *num=[NSNumber numberWithDouble:[s doubleValue]];
        if(flagReverted)
            num=[NSNumber numberWithDouble:1/[s doubleValue]];
        
        
            //Testing
        NSNumber *num1=@(num.doubleValue/100+num.doubleValue);
        [arr addObject:@{@"Bid":num, @"Ask":num1}];
    }
    
    self.graphValues=arr;
    
    

}



- (NSString *)urlRelative {
    return @"AssetPairDetailedRates";
}

-(NSDictionary *) params
{
    return @{@"period":self.period.value, @"assetId":self.assetId, @"points":@(160)};
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}

-(NSDate *) dateFromString:(NSString *) string
{
    string=[string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    string=[string substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

@end
