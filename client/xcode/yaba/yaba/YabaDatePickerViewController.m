//
//  YabaDatePickerViewController.m
//  yaba
//
//  Created by TwoPi on 16/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaDatePickerViewController.h"
#import "YabaBookmark.h"
#import "YabaUtil.h"

@interface YabaDatePickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *bmDatePicker;

@end

@implementation YabaDatePickerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationItem *navItem = self.navigationItem;
    //navItem.title = @"Set Notify Date";
    
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc]
                            initWithTitle:@"Set" style:UIBarButtonItemStylePlain
                            target:self action:@selector(setNotifyDate:)];
    
    UIBarButtonItem *unSetButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"UnSet" style:UIBarButtonItemStylePlain
                                  target:self action:@selector(unSetNotifyDate:)];
    
    navItem.rightBarButtonItems = @[unSetButton,setButton];
    
    YabaBookmark * bm = self.bm;
    if (bm.hasNotify) {
        [self.bmDatePicker setDate:[YabaUtil dateFromUTCString:bm.notifyOn]];
    }
    [self.bmDatePicker setMinimumDate:[YabaUtil addDays:nil withDays:1]];
    [self.bmDatePicker setMaximumDate:[YabaUtil addDays:nil withDays:30]];
    
}

-(IBAction)setNotifyDate:(id)sender
{
    self.bm.hasNotify = YES;
    self.bm.notifyOn = [YabaUtil dateToUTCDateString:[self.bmDatePicker date]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)unSetNotifyDate:(id)sender
{
    self.bm.hasNotify = NO;
    self.bm.notifyOn = @"1970-01-01T00:00:00Z";
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //self.bm.notifyOn = [self.bmDatePicker date];
}

@end
