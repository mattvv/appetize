//
//  RecordControlViewController.h
//  Appitize
//
//  Created by Glen Tregoning on 9/09/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScreenRecorder;

@interface RecordControlViewController : UIViewController

@property (weak, nonatomic) ScreenRecorder* recorder;

@property (strong, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *startStopRecordButton;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)closeButtonPress:(id)sender;
- (IBAction)startStopRecordButtonPress:(id)sender;

@end