//
//  LWImageDownloader.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWImageDownloader.h"

@import UIKit;

@interface LWImageDownloader()
{
    NSMutableDictionary *images;
    NSMutableDictionary *completions;
}

@end

@implementation LWImageDownloader

-(id) init
{
    self=[super init];
    
    images=[[NSMutableDictionary alloc] init];
    completions=[[NSMutableDictionary alloc] init];
    
    return self;
}

+ (instancetype)shared
{
    static LWImageDownloader *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LWImageDownloader alloc] init];
    });
    return shared;
}

-(void) downloadImageFromURLString:(NSString *) urlString withCompletion:(void(^)(UIImage *)) completion
{
    if(!urlString)
        return;
    if(images[urlString])
    {
        completion(images[urlString]);
        return;
    }
    if(completions[urlString])
    {
        completions[urlString]=completion;
        return;
    }
    completions[urlString]=completion;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *url=[NSURL URLWithString:urlString];
        if(!url)
            return;
        NSData *data=[NSData dataWithContentsOfURL:url];
        if(!data)
            return;
        UIImage *image=[UIImage imageWithData:data];
        if(image)
        {
            images[urlString]=image;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                void(^completionn)(UIImage *)=completions[urlString];
                completionn(image);
                [completions removeObjectForKey:urlString];
            });
        }
    });
}

@end
