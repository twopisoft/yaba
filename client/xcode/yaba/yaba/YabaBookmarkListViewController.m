//
//  com_twopiViewController.m
//  yaba
//
//  Created by TwoPi on 5/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkListViewController.h"
#import "YabaBookmarkDetailsViewController.h"
#import "YabaBookmark.h"
#import "YabaBookmarkStore.h"
#import "YabaBookmarkCell.h"

@interface YabaBookmarkListViewController ()

@end

@implementation YabaBookmarkListViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        for (int i=0; i<5; i++) {
            [[YabaBookmarkStore bmStore] createBm];
        }
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"YABA";
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithTitle:@"Settings" style:UIBarButtonItemStylePlain
                                target:self action:@selector(configure:)];
        
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

-(IBAction)configure:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    UINib *nib = [UINib nibWithNibName:@"YabaBookmarkCell" bundle:nil];
    
    [self.tableView registerNib:nib forCellReuseIdentifier:@"YabaBookmarkCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[YabaBookmarkStore bmStore] allBms] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    
    //UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    YabaBookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YabaBookmarkCell" forIndexPath:indexPath];
    
    NSArray *bms = [[YabaBookmarkStore bmStore] allBms];
    YabaBookmark *bm = bms[indexPath.row];
    
    cell.bmNameLabel.text = [bm name];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[bm imageUrl]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [bm setThumbnailFromImage:[UIImage imageWithData:data] withRect:CGRectMake(0, 0, 134, 75)];
        cell.bmImage.image = bm.thumbnail;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray * bms = [[YabaBookmarkStore bmStore] allBms];
        YabaBookmark * bm = [bms objectAtIndex:indexPath.row];
        [[YabaBookmarkStore bmStore] removeBm:bm];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

/*- (void)tableView:(UITableView *)tableView
                    moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[YabaBookmarkStore bmStore] moveBmAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}*/

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Accessory button tapped for row=%d",indexPath.row);
    
    YabaBookmarkDetailsViewController *detailViewController = [[YabaBookmarkDetailsViewController alloc] init];
    
    NSArray * bms = [[YabaBookmarkStore bmStore] allBms];
    YabaBookmark * selectedBm = [bms objectAtIndex:indexPath.row];
    
    detailViewController.bm = selectedBm;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}


@end
