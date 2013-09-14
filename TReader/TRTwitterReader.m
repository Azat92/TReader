//
//  TRTwitterReader.m
//  TReader
//
//  Created by Azat Almeev on 09.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import "TRTwitterReader.h"
#import "TRTwitterWorker.h"

#define kReaderHomeTimeline 1
#define kReaderUserTwits    2
#define kIdStr              @"id_str"

@interface TRTwitterReader ()
{
    NSMutableArray *_twits;
    TRTwitterWorker *twitterWorker;
    void (^changeBlock)(NSInteger changeType);
    NSInteger readerType;
    NSString *lastId;
    NSString *userName;
}
@end

@implementation TRTwitterReader

- (TRTwitterReader *)init
{
    self = [super init];
    if (!self)
        return nil;
    _twits = [NSMutableArray array];
    twitterWorker = [TRTwitterWorker sharedWorker];
    return self;
}

- (NSArray *)twits
{
    return _twits;
}

- (void)loadHomeTimelineCompletion:(void (^)(BOOL success, NSString *message))completion onChange:(void (^)(NSInteger changeType))change
{
    readerType = kReaderHomeTimeline;
    [_twits removeAllObjects];
    changeBlock = change;
    if (!twitterWorker.isSigned)
    {
        completion(NO, @"Unauthorized");
        return;
    }
    id twits = [twitterWorker.twitterEngine getHomeTimelineMaxID:nil count:30];
    if ([twits isKindOfClass:[NSError class]])
    {
        MYLog(@"Error obtainig twits: %@", [(NSError *)twits localizedDescription]);
        completion(NO, [(NSError *)twits localizedDescription]);
    }
    else if ([twits isKindOfClass:[NSArray class]])
    {
        [_twits addObjectsFromArray:twits];
        lastId = [[twits lastObject]objectForKey:kIdStr];
        completion(YES, twits);
    }
    else
    {
        MYLog(@"Unrecognized error obtaining twits");
        completion(NO, @"Unrecognized error obtaining twits");
    }
}

- (void)loadUserTwits:(NSString *)screenName completion:(void (^)(BOOL success, NSString *message))completion onChange:(void (^)(NSInteger changeType))change
{
    readerType = kReaderUserTwits;
    [_twits removeAllObjects];
    changeBlock = change;
    if (!twitterWorker.isSigned)
    {
        completion(NO, @"Unauthorized");
        return;
    }
    userName = screenName;
    id twits = [twitterWorker.twitterEngine getTimelineForUser:screenName isID:NO count:30 sinceID:nil maxID:nil];
    if ([twits isKindOfClass:[NSError class]])
    {
        MYLog(@"Error obtainig twits: %@", [(NSError *)twits localizedDescription]);
        completion(NO, [(NSError *)twits localizedDescription]);
    }
    else if ([twits isKindOfClass:[NSArray class]])
    {
        [_twits addObjectsFromArray:twits];
        lastId = [[twits lastObject]objectForKey:kIdStr];
        completion(YES, twits);
    }
    else
    {
        MYLog(@"Unrecognized error obtaining twits");
        completion(NO, @"Unrecognized error obtaining twits");
    }
}

- (void)appendTweets
{
    if (!twitterWorker.isSigned)
        return;
    
    if (readerType == kReaderHomeTimeline)
    {
        id twits = [twitterWorker.twitterEngine getHomeTimelineMaxID:lastId count:31];
        if ([twits isKindOfClass:[NSError class]])
        {
            showErrorMessage([NSString stringWithFormat:@"Error obtainig twits: %@", [(NSError *)twits localizedDescription]]);
            changeBlock(kChangeTypeAdd);
            return;
        }
        else if ([twits isKindOfClass:[NSArray class]])
        {
            [_twits addObjectsFromArray:[twits subarrayWithRange:NSRangeFromString([NSString stringWithFormat:@"1,%d", [twits count] - 1])]];
            lastId = [[twits lastObject]objectForKey:kIdStr];
            changeBlock(kChangeTypeAdd);
        }
        else
        {
            showErrorMessage(@"Unrecognized error obtaining twits");
            changeBlock(kChangeTypeAdd);
        }
    }
    
    if (readerType == kReaderUserTwits)
    {
        id twits = [twitterWorker.twitterEngine getTimelineForUser:userName isID:NO count:31 sinceID:nil maxID:lastId];
        if ([twits isKindOfClass:[NSError class]])
        {
            showErrorMessage([NSString stringWithFormat:@"Error obtainig twits: %@", [(NSError *)twits localizedDescription]]);
            changeBlock(kChangeTypeAdd);
            return;
        }
        else if ([twits isKindOfClass:[NSArray class]])
        {
            [_twits addObjectsFromArray:[twits subarrayWithRange:NSRangeFromString([NSString stringWithFormat:@"1,%d", [twits count] - 1])]];
            lastId = [[twits lastObject]objectForKey:kIdStr];
            changeBlock(kChangeTypeAdd);
        }
        else
        {
            showErrorMessage(@"Unrecognized error obtaining twits");
            changeBlock(kChangeTypeAdd);
        }
    }
}

- (void)refreshTweets
{
    if (!twitterWorker.isSigned)
        return;
    lastId = @"";

    if (readerType == kReaderHomeTimeline)
    {
        [_twits removeAllObjects];
        id twits = [twitterWorker.twitterEngine getHomeTimelineMaxID:nil count:30];
        if ([twits isKindOfClass:[NSError class]])
        {
            showErrorMessage([NSString stringWithFormat:@"Error obtainig twits: %@", [(NSError *)twits localizedDescription]]);
            changeBlock(kChangeTypeReload);
            return;
        }
        else if ([twits isKindOfClass:[NSArray class]])
        {
            [_twits addObjectsFromArray:twits];
            lastId = [[twits lastObject]objectForKey:kIdStr];
            changeBlock(kChangeTypeReload);
        }
        else
        {
            showErrorMessage(@"Unrecognized error obtaining twits");
            changeBlock(kChangeTypeReload);
        }
    }
    
    if (readerType == kReaderUserTwits)
    {
        [_twits removeAllObjects];
        id twits = [twitterWorker.twitterEngine getTimelineForUser:userName isID:NO count:30 sinceID:nil maxID:lastId];
        if ([twits isKindOfClass:[NSError class]])
        {
            showErrorMessage([NSString stringWithFormat:@"Error obtainig twits: %@", [(NSError *)twits localizedDescription]]);
            changeBlock(kChangeTypeReload);
            return;
        }
        else if ([twits isKindOfClass:[NSArray class]])
        {
            [_twits addObjectsFromArray:twits];
            lastId = [[twits lastObject]objectForKey:kIdStr];
            changeBlock(kChangeTypeReload);
        }
        else
        {
            showErrorMessage(@"Unrecognized error obtaining twits");
            changeBlock(kChangeTypeReload);
        }
    }
}

- (void)loadImageOfArticleWithLink:(NSString *)url completion:(void (^)(BOOL success, UIImage *image))completion
{
    if (!url || url == (id)[NSNull null])
    {
        completion(NO, nil);
        return;
    }
    NSMutableURLRequest* rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:rq];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        UIImage *img = [UIImage imageWithData:responseObject];
        completion(YES, img);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        MYLog(@"error '%@' in request '%@'", error.localizedDescription, operation.request.URL);
        completion(NO, nil);
    }];
    [operation start];
}

@end
