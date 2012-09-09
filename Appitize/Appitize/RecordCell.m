//
//  RecordCell.m
//  Appitize
//
//  Created by Matt Van Veenendaal on 9/9/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import "RecordCell.h"

@implementation RecordCell
@synthesize name, time;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
