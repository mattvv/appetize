//
//  RecordCell.m
//  Appitize
//
//  Created by Matt Van Veenendaal on 9/9/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "RecordCell.h"
#import "MoviePlayer.h"

@implementation RecordCell
@synthesize name, time, video;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playVideo:(id)sender {
    MoviePlayer *mp = [[MoviePlayer alloc] init];
    [mp playVideo:video withView:self.superview.superview.superview];
}

@end
