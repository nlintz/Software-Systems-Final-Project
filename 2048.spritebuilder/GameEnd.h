//
//  GameEnd.h
//  2048
//
//  Created by Nathan Lintz on 4/20/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface GameEnd : CCNode

- (void)setMessage:(NSString *)message score:(NSInteger)score;

@end
