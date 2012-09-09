//
//  Video.h
//  Appetize
//
//  Created by Matt Van Veenendaal on 9/8/12.
//  Copyright (c) 2012 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (nonatomic, retain) NSURL *assetURL;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mainLength;

@end
