//
//  GraphViewController.m
//  CalendarTracker
//
//  Created by Timothy Chong on 1/26/13.
//  Copyright (c) 2013 Timothy Chong. All rights reserved.
//

#import "GraphViewController.h"
#import "ColumnGraphView.h"
#import "TotalHoursViewController.h"
@interface GraphViewController ()

@end

@implementation GraphViewController

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
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"                     style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                        action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = customBackButton;
    self.navigationItem.title = @"Graph";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.graphView.dataSource = self.previousController;
    [self.graphView setNeedsDisplay];
    [self resetTimePeriod];
}
- (IBAction)backwardButton:(id)sender {
    [self.previousController backwardButton:sender];
    [self.graphView setNeedsDisplay];
    [self resetTimePeriod];
}

- (IBAction)forwardButton:(id)sender {
    [self.previousController forwardButton:sender];
    [self.graphView setNeedsDisplay];
    [self resetTimePeriod];
}
-(void) resetTimePeriod
{
    self.datePeriodLabel.text = self.previousController.datePeriodLabel.text;
}
-(IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];  
}
@end
