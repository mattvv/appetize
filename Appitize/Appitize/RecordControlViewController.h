//
//  RecordControlViewController.h
//  Appitize
//
//  Created by Glen Tregoning on 9/09/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordControlViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (retain, nonatomic) IBOutlet UIButton *startStopRecordButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonPress:(id)sender;
- (IBAction)startStopRecordButtonPress:(id)sender;

@end