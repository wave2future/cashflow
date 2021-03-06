// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "Category.h"
#import "AppDelegate.h"

@implementation Category

@end

@implementation Categories

-(id)init
{
    [super init];
    mCategories = nil;

    return self;
}

-(void)dealloc
{
    [mCategories release];
    [super dealloc];
}

-(void)reload
{
    [mCategories release];
    mCategories = [Category find_all:@"ORDER BY sorder"];
    [mCategories retain];
}

-(int)count
{
    return [mCategories count];
}

-(Category*)categoryAtIndex:(int)n
{
    ASSERT(mCategories != nil);
    return [mCategories objectAtIndex:n];
}

- (int)categoryIndexWithKey:(int)key
{
    int i, max = [mCategories count];
    for (i = 0; i < max; i++) {
        Category *c = [mCategories objectAtIndex:i];
        if (c.pid == key) {
            return i;
        }
    }
    return -1;
}

-(NSString*)categoryStringWithKey:(int)key
{
    int idx = [self categoryIndexWithKey:key];
    if (idx < 0) {
        return @"";
    }
    Category *c = [mCategories objectAtIndex:idx];
    return c.name;
}

-(Category*)addCategory:(NSString *)name
{
    Category *c = [[Category alloc] init];
    c.name = name;
    [mCategories addObject:c];
    [c release];

    [self renumber];

    [c save];
    return c;
}

-(void)updateCategory:(Category*)category
{
    [category save];
}

-(void)deleteCategoryAtIndex:(int)index
{
    Category *c = [mCategories objectAtIndex:index];
    [c delete];

    [mCategories removeObjectAtIndex:index];
}

- (void)reorderCategory:(int)from to:(int)to
{
    Category *c = [[mCategories objectAtIndex:from] retain];
    [mCategories removeObjectAtIndex:from];
    [mCategories insertObject:c atIndex:to];
    [c release];
	
    [self renumber];
}

-(void)renumber
{
    int i, max = [mCategories count];

    for (i = 0; i < max; i++) {
        Category *c = [mCategories objectAtIndex:i];
        c.sorder = i;
        [c save];
    }
}

@end
