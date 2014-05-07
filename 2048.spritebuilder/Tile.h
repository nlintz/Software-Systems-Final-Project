//
//  Tile.h
//  2048
//
//  Created by Nathan Lintz on 4/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNodeColor.h"

@interface Tile : CCNode
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) BOOL mergedThisRound;
@property (nonatomic, assign) BOOL selected;
-(void)updateValueDisplay;
-(void)selectTile;
-(void)deselectTile;
@end
