//
//  TRTweetShowViewController.m
//  TReader
//
//  Created by Azat Almeev on 06.09.13.
//  Copyright (c) 2013 Azat Almeev. All rights reserved.
//

#import "TRTweetShowViewController.h"
#import "TRTwitterReader.h"
#import "MBProgressHUD.h"

#define kUserTag       @"user"
#define kScreenNameTag @"screen_name"
#define kCreatedTag    @"created_at"
#define kTextTag       @"text"
#define kImageTag      @"profile_image_url"

@interface TRTweetShowViewController () <UITableViewDataSource, UITableViewDelegate>
{
    TRTwitterWorker *tweetWorker;
    TRTwitterReader *tweetReader;
    NSInteger twitsCount;
    MBProgressHUD *progressHud;
    BOOL isHomeScreen;
    NSIndexPath *selectedCell;
    
    NSDateFormatter *fromFormat, *toFormat;
}
@end

@implementation TRTweetShowViewController
@synthesize tableView = _tableView;
@synthesize userName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    isHomeScreen = userName == nil;
    twitsCount = 0;
    tweetWorker = [TRTwitterWorker sharedWorker];
    tweetReader = [[TRTwitterReader alloc]init];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(doRefresh:) forControlEvents:UIControlEventValueChanged];
    progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.labelText = @"Loading twits";

    fromFormat = [[NSDateFormatter alloc] init];
    [fromFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [fromFormat setDateStyle:NSDateFormatterLongStyle];
    [fromFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
    [fromFormat setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
    toFormat = [fromFormat copy];
    [toFormat setDateFormat:@"dd MMM yyyy HH:mm"];
    if (!isHomeScreen)
        self.navigationItem.rightBarButtonItem = nil;

    [tweetWorker loginFromController:self completion:^(BOOL success)
    {
        if (success)
            [self loadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isHomeScreen)
        [self setTitle:tweetWorker.userName];
    else
        [self setTitle:userName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowAnother"])
    {
        NSDictionary *twit = [tweetReader.twits objectAtIndex:selectedCell.row];
        [(TRTweetShowViewController *)segue.destinationViewController setUserName:[[twit objectForKey:kUserTag] objectForKey:kScreenNameTag]];
    }
}

#pragma mark - IB Actions
- (IBAction)exit:(id)sender
{
    [tweetWorker logout];
    [self performBlock:^(id sender)
    {
        [tweetWorker loginFromController:self completion:^(BOOL success)
        {
            if (success)
                [self loadData];
        }];
    } afterDelay:0.1];
}

- (void)doRefresh:(CKRefreshControl *)sender
{
    [tweetReader refreshTweets];
}

#pragma mark - Table View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return twitsCount + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == twitsCount ? 44 : 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TwitCellIdentifier";
    static NSString *addCellIdentifier = @"SimpleTableIdentifier";
    
    if (indexPath.row < twitsCount)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        NSDictionary *twit = [tweetReader.twits objectAtIndex:indexPath.row];

        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        imageView.image = nil;
        [tweetReader loadImageOfArticleWithLink:[[twit objectForKey:kUserTag] objectForKey:kImageTag] completion:^(BOOL success, UIImage *img)
         {
             if (success)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                     [imageView setImage:img];
                 });
             }
         }];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
        nameLabel.text = [[twit objectForKey:kUserTag]objectForKey:kScreenNameTag];
        
        UILabel *textLabel = (UILabel *)[cell viewWithTag:3];
        textLabel.text = [twit objectForKey:kTextTag];
        
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
        NSDate *newDate = [fromFormat dateFromString:[twit objectForKey:kCreatedTag]];
        timeLabel.text = [toFormat stringFromDate:newDate];
        
        cell.accessoryType = isHomeScreen ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellIdentifier];
        cell.textLabel.text = @"Load more";
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == twitsCount)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tweetReader appendTweets];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCell = indexPath;
    if (isHomeScreen)
        return indexPath;
    if (indexPath.row == twitsCount)
        return indexPath;
    return nil;
}

#pragma mark - private
- (void)loadData
{
    if (isHomeScreen)
        [tweetReader loadHomeTimelineCompletion:^(BOOL success, NSString *message)
         {
             [progressHud hide:YES];
             if (!success)
                 showErrorMessage(message);
             else
             {
                 twitsCount = tweetReader.twits.count;
                 [self.tableView reloadData];
             }
         } onChange:^(NSInteger changeType)
         {
             if (changeType == kChangeTypeAdd)
             {
                 NSMutableArray *indexPaths = [NSMutableArray array];
                 for (int i = twitsCount; i < tweetReader.twits.count; i++)
                     [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                 twitsCount = tweetReader.twits.count;
                 [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
             }
             if (changeType == kChangeTypeReload)
             {
                 twitsCount = tweetReader.twits.count;
                 [self.tableView reloadData];
                 [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
             }
         }];
    else
        [tweetReader loadUserTwits:userName completion:^(BOOL success, NSString *message)
         {
             [progressHud hide:YES];
             if (!success)
                 showErrorMessage(message);
             else
             {
                 twitsCount = tweetReader.twits.count;
                 [self.tableView reloadData];
             }
         } onChange:^(NSInteger changeType)
         {
             if (changeType == kChangeTypeAdd)
             {
                 NSMutableArray *indexPaths = [NSMutableArray array];
                 for (int i = twitsCount; i < tweetReader.twits.count; i++)
                     [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                 twitsCount = tweetReader.twits.count;
                 [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
             }
             if (changeType == kChangeTypeReload)
             {
                 twitsCount = tweetReader.twits.count;
                 [self.tableView reloadData];
                 [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
             }
         }];
}

@end
