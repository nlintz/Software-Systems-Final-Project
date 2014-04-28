//
//  Seal.m
//  PeevedPenguins
//
//  Created by Nathan Lintz on 4/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
    self.alive = YES;
}

- (id)init {
    self = [super init];
    return self;
}

@end
