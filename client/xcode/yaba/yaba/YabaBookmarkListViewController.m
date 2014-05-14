//
//  com_twopiViewController.m
//  yaba
//
//  Created by TwoPi on 5/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkListViewController.h"
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
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
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
        [bm setThumbnailFromImage:[UIImage imageWithData:data] withRect:[cell.bmImage bounds]];
        cell.bmImage.image = bm.thumbnail;
    }];
    
    return cell;
}

@end
