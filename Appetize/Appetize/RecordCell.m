//
//  RecordCell.m
//  Appetize
//
//  Created by Matt Van Veenendaal on 9/9/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "RecordCell.h"
#import "MoviePlayer.h"

@implementation RecordCell
@synthesize name, time, video, moviePlayer;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        moviePlayer = [[MoviePlayer alloc] init];
    return self;
}
 
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
    [moviePlayer playVideo:video withView:self.superview.superview.superview];
}

+(void)_keepAtLinkTime {
}

@end
