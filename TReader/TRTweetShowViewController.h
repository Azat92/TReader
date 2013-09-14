//
//  TRTweetShowViewController.h
//  TReader
//
//  Created by Azat Almeev on 06.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTwitterWorker.h"

@interface TRTweetShowViewController : UITableViewController

/**
 * @brief Table View Outlet
 */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

/**
 * @brief Set this parameter to display tweits for certain user. Else will be show logged user name
 */
@property (nonatomic, retain) NSString *userName;

/**
 * @brief Logout from program
 * @param sender Object that call that method
 */
- (IBAction)exit:(id)sender;

@end
