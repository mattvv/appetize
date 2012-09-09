//
//  RecordControlViewController.m
//  Appitize
//
//  Created by Glen Tregoning on 9/09/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "RecordControlViewController.h"
#import "Appitize.h"

@interface RecordControlViewController ()

@end

@implementation RecordControlViewController

- (id)init
{
    self = [super initWithNibName:@"RecordControlViewController" bundle:[Appitize frameworkBundle]];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRecordTimeLabel:nil];
    [self setCloseButton:nil];
    [self setStartStopRecordButton:nil];
    [super viewDidUnload];
}

- (IBAction)closeButtonPress:(id)sender {
    
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)startStopRecordButtonPress:(id)sender {
    
}
@end
