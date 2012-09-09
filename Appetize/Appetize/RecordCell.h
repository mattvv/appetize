//
//  RecordCell.h
//  Appetize
//
//  Created by Matt Van Veenendaal on 9/9/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"
#import "MoviePlayer.h"

@interface RecordCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) Video * video;
@property (nonatomic, retain) MoviePlayer *moviePlayer;

- (IBAction)playVideo:(id)sender;
+(void)_keepAtLinkTime;

@end
