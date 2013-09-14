//
//  TRTwitterReader.h
//  TReader
//
//  Created by Azat Almeev on 06.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRServices.h"
#import "AFNetworking.h"
#import "FHSTwitterEngine.h"

@interface TRTwitterWorker : NSObject

/**
 * @brief Indicates if any user logged in to program
 */
@property (nonatomic, readonly) BOOL isSigned;

/**
 * @brief An engine that knows API methods to work with Twitter
 */
@property (nonatomic, retain, readonly) FHSTwitterEngine *twitterEngine;

/**
 * @brief Returns the name of logged user
 */
@property (nonatomic, retain, readonly) NSString *userName;

/**
 * @brief Returns a singleton instance of interface
 */
+ (TRTwitterWorker *)sharedWorker;

/**
 * @brief Call this ti show login view
 * @param controller A controller from which will be animated showing login view
 * @param block A block which will be call when auth process done
 */
- (void)loginFromController:(UIViewController *)controller completion:(void(^)(BOOL success))block;

/**
 * @brief Call to logout user from program
 */
- (void)logout;
@end
