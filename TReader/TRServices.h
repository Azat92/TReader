//
//  TRServices.h
//  TReader
//
//  Created by Azat Almeev on 06.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG
#define MYLog(args...) NSLog(@"%@", [NSString stringWithFormat: args])
#else
#define MYLog(args...)    // do nothing.
#endif

static inline void showErrorMessage(NSString* message)
{
    if (!message || [message isEqualToString:@""])
        message = @"Unrecognized error occured";
    UIAlertView* al_view=[[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [al_view show];
}