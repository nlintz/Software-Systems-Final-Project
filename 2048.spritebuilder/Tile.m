//
//  Tile.m
//  2048
//
//  Created by Nathan Lintz on 4/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Tile.h"

@implementation Tile
{
    CCLabelTTF *_valueLabel;
    CCNodeColor *_backgroundNode;
}
- (id)init {
    self = [super init];
    if (self) {
        self.value = (arc4random()%2+1) * 2;
        self.selected = FALSE;
    }
    return self;
}

- (void)updateValueDisplay
{
    _valueLabel.string = [NSString stringWithFormat:@"%d", self.value];
    CCColor *backgroundColor = nil;
    
    if (self.selected) {
        backgroundColor = [CCColor redColor];
        [_backgroundNode setOpacity:.5f];
    } else {
    
    [_backgroundNode setOpacity:1.0f];
    switch (self.value) {
        case 2:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:20.f/255.f blue:80.f/255.f];
            break;
        case 4:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:20.f/255.f blue:140.f/255.f];
            break;
        case 8:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:60.f/255.f blue:220.f/255.f];
            break;
        case 16:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:120.f/255.f blue:120.f/255.f];
            break;
        case 32:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:160.f/255.f blue:120.f/255.f];
            break;
        case 64:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:160.f/255.f blue:60.f/255.f];
            break;
        case 128:
            backgroundColor = [CCColor colorWithRed:50.f/255.f green:160.f/255.f blue:60.f/255.f];
            break;
        case 256:
            backgroundColor = [CCColor colorWithRed:80.f/255.f green:120.f/255.f blue:60.f/255.f];
            break;
        case 512:
            backgroundColor = [CCColor colorWithRed:140.f/255.f green:70.f/255.f blue:60.f/255.f];
            break;
        case 1024:
            backgroundColor = [CCColor colorWithRed:170.f/255.f green:30.f/255.f blue:60.f/255.f];
            break;
        case 2048:
            backgroundColor = [CCColor colorWithRed:220.f/255.f green:30.f/255.f blue:30.f/255.f];
            break;
        default:
            backgroundColor = [CCColor greenColor];
            break;
        }
    }
    _backgroundNode.color = backgroundColor;
}

- (void)selectTile
{
    self.selected = TRUE;
    [self updateValueDisplay];
}

- (void)deselectTile
{
    self.selected = FALSE;
    [self updateValueDisplay];
}

- (void)didLoadFromCCB {
    [self updateValueDisplay];
}

@end
