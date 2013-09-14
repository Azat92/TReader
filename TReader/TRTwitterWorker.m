//
//  TRTwitterReader.m
//  TReader
//
//  Created by Azat Almeev on 06.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import "TRTwitterWorker.h"

#define kOAuthConsumerKey	 @"IXFI5xGLFMwVrEb3rMhvQ"
#define kOAuthConsumerSecret @"eanYC6vlvCP6aaFSN0erCTPgSjGA6CCNMiU6RyQpWQ"

@implementation TRTwitterWorker
@synthesize twitterEngine = _twitterEngine;

static TRTwitterWorker *shared = nil;

- (BOOL)isSigned
{
    return _twitterEngine.isAuthorized;
}

- (NSString *)userName
{
    return _twitterEngine.loggedInUsername;
}

+ (TRTwitterWorker *)sharedWorker
{
    if (!shared)
        shared = [[TRTwitterWorker alloc]init];
    return shared;
}

- (TRTwitterWorker *)init
{
    self = [super init];
    if (!self)
        return nil;
    _twitterEngine = [FHSTwitterEngine sharedEngine];
    [_twitterEngine permanentlySetConsumerKey:kOAuthConsumerKey andSecret:kOAuthConsumerSecret];
    [_twitterEngine loadAccessToken];
    return self;
}

- (void)loginFromController:(UIViewController *)lcontroller completion:(void(^)(BOOL success))block
{
    if (self.isSigned)
    {
        block(YES);
        return;
    }
    [_twitterEngine showOAuthLoginControllerFromViewController:lcontroller withCompletion:^(BOOL success)
    {
        if (success)
        {
            MYLog(@"Login success");
        }
        else
        {
            MYLog(@"O noes!!! Logen falyur!!!");
        }
        block(success);
    }];
}

- (void)logout
{
    [_twitterEngine clearAccessToken];
}

@end
