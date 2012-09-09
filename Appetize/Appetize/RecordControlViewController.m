//
//  RecordControlViewController.m
//  Appetize
//
//  Created by Glen Tregoning on 9/09/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "RecordControlViewController.h"
#import "Appetize.h"
#import "ScreenRecorder.h"
#import "RecordCell.h"
#import "Video.h"

@interface RecordControlViewController ()

- (void) updateStartStopButtonTitle;
- (void) closeViewController:(void (^)(BOOL finished))completion;

@end

@implementation RecordControlViewController

@synthesize recentTableView;

- (id)init
{
    self = [super initWithNibName:@"RecordControlViewController" bundle:[Appetize frameworkBundle]];
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
    
    [self updateStartStopButtonTitle];
}

- (void)viewDidAppear:(BOOL)animated {
    [self reloadData];
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

#pragma mark - Reload Method

- (void) reloadData
{
    [recentTableView reloadData];
    if ([[Appetize sharedEngine].lastVideos count] > 0) {
        Video *video = [[Appetize sharedEngine].lastVideos lastObject];
        [self.recordTimeLabel setText:video.mainLength];
    }
}


#pragma mark - tableview shit

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[Appetize sharedEngine].lastVideos count];
    if (count > 4)
        count = 4;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RecordCell *cell = (RecordCell*)[tableView dequeueReusableCellWithIdentifier: @"RecordCellIdentifier"];
	if (cell == nil) {
		cell = [[[Appetize frameworkBundle] loadNibNamed:@"RecordCell" owner:self options:nil] lastObject];
	}
    
    Video *video = [[Appetize sharedEngine].lastVideos objectAtIndex:indexPath.row];
    cell.name.text = video.name;
    cell.time.text = video.time;
    cell.video = video;
    
    return cell;
}

- (IBAction)closeButtonPress:(id)sender {
    [self closeViewController:nil];
}

- (void) closeViewController:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (completion)
        {
            completion(finished);
        }
    }];
}

- (void)updateStartStopButtonTitle
{
    if (self.recorder.recording == YES)
    {
        self.startStopRecordButton.titleLabel.text = @"Stop recording";
    }
    else
    {
        self.startStopRecordButton.titleLabel.text = @"Start recording";
    }
}

- (IBAction)startStopRecordButtonPress:(id)sender {
    
    if (self.recorder.recording)
    {
        [self.recorder stopRecording];
    }
    else
    {
        [self closeViewController:^(BOOL finished) {
            [self.recorder startRecording];
        }];
    }
    [self updateStartStopButtonTitle];
}

@end
