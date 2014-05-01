//
//  LevelOverScreen.m
//  PeevedPenguins
//
//  Created by Nathan Lintz on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelOverScreen.h"

@implementation LevelOverScreen

-(void)nextLevel {
    [self.gamePlay loadLevel];
    [self.parent removeChild:self];
}

@end
