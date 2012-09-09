//
//  RecordControlViewController.m
//  Appitize
//
//  Created by Glen Tregoning on 9/09/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "RecordControlViewController.h"
#import "Appitize.h"
#import "RecordCell.h"
#import "Video.h"

@interface RecordControlViewController ()

@end

@implementation RecordControlViewController

@synthesize recentTableView;

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

#pragma mark - tableview shit

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Appitize sharedEngine].lastVideos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RecordCell *cell = (RecordCell*)[tableView dequeueReusableCellWithIdentifier: @"RecordCell"];
	if (cell == nil) {
		cell = [[[Appitize frameworkBundle] loadNibNamed:@"RecordCell" owner:self options:nil] lastObject];
	}
    
    Video *video = [[Appitize sharedEngine].lastVideos objectAtIndex:indexPath.row];
    cell.name.text = video.name;
    cell.time.text = video.time;
    
    return cell;
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
