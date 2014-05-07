//
//  Grid.m
//  2048
//
//  Created by Nathan Lintz on 4/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Tile.h"
#import "GameEnd.h"

@implementation Grid
{
    CGFloat _columnWidth;
    CGFloat _columnHeight;
    CGFloat _tileMarginVertical;
    CGFloat _tileMarginHorizontal;
    NSMutableArray *_gridArray;
    NSNull *_noTile;
    Tile *_selectedTile;
}

static const NSInteger GRID_SIZE = 4;
static const NSInteger START_TILES = 2;
static const NSInteger WIN_TILE = 2048;


- (void)setupBackground
{
    
    CCNode *tile = [CCBReader load:@"Tile"];
    _columnWidth = tile.contentSize.width;
    _columnHeight = tile.contentSize.height;
    
    _tileMarginHorizontal = (self.contentSize.width - (GRID_SIZE * _columnWidth)) / (GRID_SIZE+1);
    _tileMarginVertical = (self.contentSize.height - (GRID_SIZE * _columnWidth)) / (GRID_SIZE+1);
    
    float x = _tileMarginHorizontal;
    float y = _tileMarginVertical;
    
    for (int i = 0; i < GRID_SIZE; i++)
    {
        x = _tileMarginHorizontal;
        for (int j = 0; j < GRID_SIZE; j++)
        {
            CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor grayColor]];
            backgroundTile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
            backgroundTile.position = ccp(x, y);
            [self addChild:backgroundTile];
            x += _columnWidth + _tileMarginHorizontal;
        }
        y += _columnHeight + _tileMarginVertical;
    }
}

- (CGPoint)positionForColumn:(NSInteger)column row:(NSInteger)row {
    NSInteger x = _tileMarginHorizontal + column * (_tileMarginHorizontal + _columnWidth);
    NSInteger y = _tileMarginVertical + row * (_tileMarginVertical + _columnHeight);
    return CGPointMake(x, y);
}

- (CGPoint)columnForPosition:(NSInteger)x y:(NSInteger)y {
    UIView *view = [[CCDirector sharedDirector] view];
    NSInteger xOffset = (view.bounds.size.width - self.contentSize.width)/2;
    NSInteger yOffset = (view.bounds.size.height - self.contentSize.height)/2;
    
    NSInteger column = (x - _tileMarginHorizontal - xOffset)/(_tileMarginHorizontal+_columnWidth);
    NSInteger row = (y - _tileMarginVertical - yOffset)/(_tileMarginVertical+_columnHeight);
//    column = column;
    row = GRID_SIZE - 1 - row;
    return CGPointMake(column, row);
}

- (void)addTileAtColumn:(NSInteger)column row:(NSInteger)row {
    Tile *tile = (Tile *) [CCBReader load:@"Tile"];
    _gridArray[column][row] = tile;
    tile.scale = 0.f;
    [self addChild:tile];
    tile.position = [self positionForColumn:column row:row];
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.3f];
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.2f scale:1.f];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, scaleUp]];
    [tile runAction:sequence];
}

- (void)spawnRandomTile {
    BOOL spawned = FALSE;

    while (!spawned) {
        NSInteger randomRow = arc4random() % GRID_SIZE;
        NSInteger randomColumn = arc4random() % GRID_SIZE;
        BOOL positionFree = (_gridArray[randomColumn][randomRow] == _noTile);
        if (positionFree) {
            [self addTileAtColumn:randomColumn row:randomRow];
            spawned = TRUE;
        }
    }
}

- (void)spawnStartTiles {
    for (int i = 0; i < START_TILES; i++)
    {
        [self spawnRandomTile];
    }
}

- (void)didLoadFromCCB {
    [self setupBackground];
    
    _noTile = [NSNull null];
    _gridArray = [NSMutableArray array];
    for (int i = 0; i < GRID_SIZE; i++) {
        _gridArray[i] = [NSMutableArray array];
        for (int j = 0; j < GRID_SIZE; j++) {
            _gridArray[i][j] = _noTile;
        }
    }
    [self spawnStartTiles];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view]addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = FALSE;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:tap];

}

-(void)swipeLeft
{
    [self move:ccp(-1, 0)];
}

-(void)swipeRight
{
    [self move:ccp(1, 0)];
}

-(void)swipeUp
{
    [self move:ccp(0, 1)];
}

-(void)swipeDown
{
    [self move:ccp(0, -1)];
}

- (void)tap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint tapLocation = [sender locationInView:[sender.view self]];
        CGPoint gridPosition = [self columnForPosition:tapLocation.x y:tapLocation.y];
        NSInteger column = (int)gridPosition.x;
        NSInteger row = (int)gridPosition.y;
        Tile *selectedTile = [self tileForIndex:column y:row];
        if (![selectedTile isEqual:_noTile]) {
            [_selectedTile deselectTile]; // Deselect the currently selected tile
            if ([selectedTile isEqual:_selectedTile]) {
                _selectedTile = NULL;
                return;
            } else {
                [selectedTile selectTile]; // Select the currently selected tile
                _selectedTile = selectedTile;
            }
            
        }
    }
}

- (void)move:(CGPoint)direction {
    // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
    //bottom left corner
    NSInteger currentX = 0;
    NSInteger currentY = 0;
    BOOL movedTilesThisRound = FALSE;
    // Move to relevant edge by applying direction until reaching border
    while ([self indexValid:currentX y:currentY]) {
        CGFloat newX = currentX + direction.x;
        CGFloat newY = currentY + direction.y;
        if ([self indexValid:newX y:newY]) {
            currentX = newX;
            currentY = newY;
        } else {
            break;
        }
    }
    // store initial row value to reset after completing each column
    NSInteger initialY = currentY;
    // define changing of x and y value (moving left, up, down or right?)
    NSInteger xChange = -direction.x;
    NSInteger yChange = -direction.y;
    if (xChange == 0) {
        xChange = 1;
    }
    if (yChange == 0) {
        yChange = 1;
    }
    // visit column for column
    while ([self indexValid:currentX y:currentY]) {
        while ([self indexValid:currentX y:currentY]) {
            // get tile at current index
            Tile *tile = _gridArray[currentX][currentY];
            if ([tile isEqual:_noTile] || [tile isEqual:_selectedTile]) {
                // if there is no tile at this index -> skip
                currentY += yChange;
                continue;
            }
            // store index in temp variables to change them and store new location of this tile
            NSInteger newX = currentX;
            NSInteger newY = currentY;
            /* find the farthest position by iterating in direction of the vector until we reach border of grid or an occupied cell*/
            while ([self indexValidAndUnoccupied:newX+direction.x y:newY+direction.y]) {
                newX += direction.x;
                newY += direction.y;
            }

            BOOL performMove = false;
            if ([self indexValid:newX+direction.x y:newY+direction.y]) {
                // get the other tile
                NSInteger otherTileX = newX + direction.x;
                NSInteger otherTileY = newY + direction.y;
                Tile *otherTile = _gridArray[otherTileX][otherTileY];
                // compare value of other tile and also check if the other thile has been merged this round
                if (tile.value == otherTile.value && !tile.mergedThisRound) {
                    // merge tiles
                    [self mergeTileAtIndex:currentX y:currentY withTileAtIndex:otherTileX y:otherTileY];
                    movedTilesThisRound = TRUE;
                    
                } else {
                    // we cannot merge so we want to perform a move
                    performMove = TRUE;
                }
            } else {
                // we cannot merge so we want to perform a move
                performMove = TRUE;
            }
            if (performMove) {
                // Move tile to furthest position
                if (newX != currentX || newY !=currentY) {
                    // only move tile if position changed
                    [self moveTile:tile fromIndex:currentX oldY:currentY newX:newX newY:newY];
                    movedTilesThisRound = TRUE;
                }
            }

            currentY += yChange;
        }
        // move to the next column, start at the inital row
        currentX += xChange;
        currentY = initialY;
    }
    if (movedTilesThisRound) {
        [self nextRound];
    }
}

- (void)nextRound
{
    [self spawnRandomTile];
    for (int i=0; i<GRID_SIZE; i++) {
        for (int j=0; j<GRID_SIZE; j++) {
            Tile *tile = _gridArray[i][j];
            if (![tile isEqual:_noTile]) {
                tile.mergedThisRound = FALSE;
            }
        }
    }
    BOOL movePossible = [self movePossible];
    if (!movePossible) {
        [self lose];
    }
}

- (BOOL)movePossible {
    for (int i=0; i<GRID_SIZE; i++) {
        for (int j=0; j<GRID_SIZE; j++) {
            Tile *tile = _gridArray[i][j];
            
            if ([tile isEqual:_noTile]) {
                return TRUE;
            } else {
                Tile *topNeighbor = [self tileForIndex:i y:j+1];
                Tile *bottomNeighbor = [self tileForIndex:i y:j-1];
                Tile *leftNeighbor = [self tileForIndex:i-1 y:j];
                Tile *rightNeighbor = [self tileForIndex:i+1 y:j];
                
                NSArray *neighbors = @[topNeighbor, bottomNeighbor, leftNeighbor, rightNeighbor];
                for (id neighborTile in neighbors) {
                    if (neighborTile != _noTile) {
                        Tile *neighbour = (Tile *)neighborTile;
                        if (neighbour.value == tile.value) {
                            return TRUE;
                        }
                    }
                }
            }
        }
    }
}

- (void)lose {
    [self endGameWithMessage:@"you lose!"];
}

- (id)tileForIndex: (NSInteger)x y:(NSInteger)y {
    if (![self indexValid:x y:y]) {
        return _noTile;
    } else {
        return _gridArray[x][y];
    }
}

-(BOOL)indexValid:(NSInteger)x y:(NSInteger)y
{
    BOOL indexValid = TRUE;
    indexValid &= x >= 0;
    indexValid &= y >= 0;
    
    if (indexValid) {
        indexValid &= x < (int) [_gridArray count];
        if (indexValid) {
            indexValid &= y < (int) [(NSMutableArray *)_gridArray[x] count];
        }
    }
    
    return indexValid;
}

- (BOOL)indexValidAndUnoccupied: (NSInteger)x y:(NSInteger)y
{
    BOOL indexValid = [self indexValid:x y:y];
    if (!indexValid){
        return FALSE;
    }
    BOOL unoccupied = [_gridArray[x][y] isEqual:(_noTile)];
    return unoccupied;
}

- (void)moveTile:(Tile *)tile fromIndex:(NSInteger)oldX oldY:(NSInteger)oldY newX:(NSInteger)newX newY:
    (NSInteger)newY {
    _gridArray[newX][newY] = _gridArray[oldX][oldY];
    _gridArray[oldX][oldY] = _noTile;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:newPosition];
    [tile runAction:moveTo];
    
}

- (void)mergeTileAtIndex:(NSInteger)x y:(NSInteger)y withTileAtIndex:(NSInteger)xOtherTile y:(NSInteger)yOtherTile {
    Tile *mergedTile = _gridArray[x][y];
    Tile *otherTile = _gridArray[xOtherTile][yOtherTile];
    self.score += mergedTile.value + otherTile.value;
    otherTile.value *= 2;
    otherTile.mergedThisRound = TRUE;
    if (otherTile.value == WIN_TILE) {
        [self win];
    }
    _gridArray[x][y] = _noTile;
    // 2) update the UI
    CGPoint otherTilePosition = [self positionForColumn:xOtherTile row:yOtherTile];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:otherTilePosition];
    CCActionRemove *remove = [CCActionRemove action];
    CCActionCallBlock *mergeTile = [CCActionCallBlock actionWithBlock:^{
        [otherTile updateValueDisplay];
    }];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[moveTo, mergeTile, remove]];
    [mergedTile runAction:sequence];
}

- (void)win {
    [self endGameWithMessage:@"You Win!"];
}

- (void) endGameWithMessage:(NSString *)message {
    
    GameEnd *gameEndPopover = (GameEnd *)[CCBReader load:@"GameEnd"];
    gameEndPopover.positionType = CCPositionTypeNormalized;
    gameEndPopover.position = ccp(0.5, 0.5);
    gameEndPopover.zOrder = INT_MAX;
    [gameEndPopover setMessage:message score:self.score];
    [self addChild:gameEndPopover];
    
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
    if (self.score > [highScore intValue]) {
        highScore = [NSNumber numberWithInt:self.score];
        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"highscore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}



@end
