//
//  OnCampusEventsViewController.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/6/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
#import "NewsContentViewController.h"
#import "TFHpple.h"
#import "News.h"
#import "Constants.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)parseNews:(NSMutableArray *)newsArray atURL:(NSString *)webURL withQuery:(NSString *)query
{
    //NSLog(@"The news array originally has:\n%@", newsArray);
    NSURL *newsURL = [NSURL URLWithString:webURL];
    NSData *newsHTML = [NSData dataWithContentsOfURL:newsURL];
    TFHpple *newsParser = [TFHpple hppleWithHTMLData:newsHTML];
    NSArray *newsNodes = [newsParser searchWithXPathQuery:query];
    for (TFHppleElement *element in newsNodes) {
        News *article = [[News alloc] init];
        [newsArray addObject:article];
        [article setTitle:[[element firstChild] content]];
        [article setUrl:[element objectForKey:@"href"]];
    }
    //NSLog(@"The news array now has:\n%@", newsArray);
}

- (void)loadNews {
    NSMutableArray *newsArticles = [[NSMutableArray alloc] initWithCapacity:0];
    [self parseNews:newsArticles atURL:[NSString stringWithFormat:@"%s",
                                       LINK_ESPN_ND_BLOG
                                       ]
                             withQuery:[NSString stringWithFormat:@"%s",
                                       QUERY_ESPN_ND_BLOG
                                       ]];
    [self parseNews:newsArticles atURL:[NSString stringWithFormat:@"%s",
                                       LINK_THE_OBSERVER
                                       ]
                             withQuery:[NSString stringWithFormat:@"%s",
                                       QUERY_THE_OBSERVER
                                       ]];
    [self parseNews:newsArticles atURL:[NSString stringWithFormat:@"%s",
                                       LINK_ESPN_NCAAF
                                       ]
                             withQuery:[NSString stringWithFormat:@"%s",
                                       QUERY_ESPN_NCAAF
                                       ]];
    self.newsList = newsArticles;
    
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self loadNews];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"OnCampusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = @"News";
    
    
    return cell;
    
    return nil;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.newsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NewsCell";

    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NewsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    News *currNews = [self.newsList objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text          = currNews.title;
    cell.detailTextLabel.text    = @"Testing";
    cell.url                     = currNews.url;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = (NewsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"DisplayNews" sender:cell];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DisplayNews"]){
        NewsContentViewController *webBrowser = [segue destinationViewController];
        NSString *webLink = [(NewsTableViewCell *)sender url];
        [webBrowser setUrl:webLink];
    }
}

@end
