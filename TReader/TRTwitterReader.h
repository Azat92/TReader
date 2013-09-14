//
//  TRTwitterReader.h
//  TReader
//
//  Created by Azat Almeev on 09.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kChangeTypeAdd    1
#define kChangeTypeReload 2

@interface TRTwitterReader : NSObject

/**
 * @brief An array of NSDictionary objects - twits that come from server
 */
@property (nonatomic, retain, readonly) NSArray *twits;

/**
 * @brief Call method to load home timeline for logged user. Call once for view controller
 * @param completion A block that calls when loading finished
 * @param change A block that will be call when anything will change (appending new twits or refresh)
 */
- (void)loadHomeTimelineCompletion:(void (^)(BOOL success, NSString *message))completion onChange:(void (^)(NSInteger changeType))change;

/**
 * @brief Call this method to get twits written by certain user. Call once for view controller
 * @param screenName A screen name of user to load twits
 * @param completion A block that calls when loading done
 * @param change A block that will be call when something change (appending new twits or refresh)
 */
- (void)loadUserTwits:(NSString *)screenName completion:(void (^)(BOOL success, NSString *message))completion onChange:(void (^)(NSInteger changeType))change;

/**
 * @brief Call to load more twits in current mode (home timeline / user twits)
 */
- (void)appendTweets;

/**
 * @brief Call to refresh twits in current mode (home timeline / user twits)
 */
- (void)refreshTweets;

/**
 * @brief Call to async load image
 * @param url A url of image
 * @param completion Block that call when loading done
 */
- (void)loadImageOfArticleWithLink:(NSString *)url completion:(void (^)(BOOL success, UIImage *image))completion;
@end
