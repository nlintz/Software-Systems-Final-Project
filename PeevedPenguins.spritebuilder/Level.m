//
//  Level.m
//  PeevedPenguins
//
//  Created by Nathan Lintz on 4/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level.h"

@implementation Level
@synthesize numSeals;
-(id) initWithLevelName:(NSString *)levelName numSeals:(NSInteger)numSeals {
    self = [super init];
    if (self) {
        _levelName = levelName;
        self.numSeals = numSeals;
    }
    return self;
}

- (NSString *)levelName {
    return _levelName;
}

- (void)updateNumSeals:(NSInteger)sealsDestroyed {
    self.numSeals -= sealsDestroyed;
}
@end
