//
//  ViewController.m
//  Coach Marks
//
//  Created by Darin Doria on 4/2/14.
//  Copyright (c) 2014 Darin Doria. All rights reserved.
//

#import "ViewController.h"
#import "DDCoachMarksView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:CGRectMake(6, 24, 40, 40)],
                                @"caption": @"Synchronize your mail",
                                @"shape": @"circle",
                                @"font": [UIFont boldSystemFontOfSize:14.0]
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:CGRectMake(275, 24, 40, 40)],
                                @"caption": @"Create a new message",
                                @"shape": @"circle",
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:CGRectMake(0, 125, 320, 60)],
                                @"caption": @"Swipe for more options",
                                @"shape": @"square",
                                @"swipe": @"YES"
                                },
                            ];
    
    DDCoachMarksView *coachMarksView = [[DDCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    
    [self.view addSubview:coachMarksView];
    [coachMarksView start];
}

@end
