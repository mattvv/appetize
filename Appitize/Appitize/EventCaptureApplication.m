//
//  EventCaptureApplication.m
//  Appitize
//
//  Created by Glen Tregoning on 8/09/12.
//  Copyright (c) 2012 Glen Tregoning. All rights reserved.
//

#import "EventCaptureApplication.h"

@implementation EventCaptureApplication

- (void)sendEvent:(UIEvent*)event {
    //handle the event (you will probably just reset a timer)

    NSLog(@"Event: %@", event);
    
    [super sendEvent:event];
}


@end
