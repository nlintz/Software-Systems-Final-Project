//
//  Level.h
//  PeevedPenguins
//
//  Created by Nathan Lintz on 4/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject
{
    NSString * _levelName;
}
@property (nonatomic, assign) NSInteger numSeals;

-(id)initWithLevelName:(NSString *)levelName numSeals:(NSInteger)numSeals;
-(void)updateNumSeals:(NSInteger)sealsDestroyed;
- (NSString *)levelName;
@end
