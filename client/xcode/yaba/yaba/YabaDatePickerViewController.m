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
    navItem.title = @"Set Notify Date";
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                            initWithTitle:@"Set" style:UIBarButtonItemStylePlain
                            target:self action:@selector(setNotifyDate:)];
    
    navItem.rightBarButtonItem = bbi;
    
    YabaBookmark * bm = self.bm;
    if (bm.hasNotify) {
        [self.bmDatePicker setDate:bm.notifyOn];
    }
    [self.bmDatePicker setMinimumDate:[NSDate date]];
    [self.bmDatePicker setMaximumDate:[YabaUtil addDays:nil withDays:30]];
    
}

-(IBAction)setNotifyDate:(id)sender
{
    self.bm.notifyOn = [self.bmDatePicker date];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //self.bm.notifyOn = [self.bmDatePicker date];
}

@end
