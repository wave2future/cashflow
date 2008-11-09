// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Category.h"
#import "AppDelegate.h"

@implementation Category
@synthesize pkey, name, sorder;
@end

@implementation Categories

@synthesize db;

-(id)init
{
	[super init];
	categories = nil;

	return self;
}

-(void)dealloc
{
	if (categories != nil) {
		[categories release];
	}
	[super dealloc];
}

-(void)reload
{
	ASSERT(db != nil);
	if (categories != nil) {
		[categories release];
	}
	categories = [db loadCategories];
}

-(int)categoryCount
{
	return [categories count];
}

-(Category*)categoryAtIndex:(int)n
{
	ASSERT(categories != nil);
	return [categories objectAtIndex:n];
}

-(Category*)categoryWithKey:(int)key
{
	int i, max = [categories count];
	for (i = 0; i < max; i++) {
		Category *c = [categories objectAtIndex:i];
		if (c.pkey == key) {
			return c;
		}
	}
	return nil;
}

-(NSString*)categoryStringWithKey:(int)key
{
	Category *c = [self categoryWithKey:key];
	if (c == nil) {
		return nil;
	}
	return c.name;
}

-(Category*)addCategory:(NSString *)name
{
	Category *c = [[Category alloc] init];
	c.name = name;
	[categories addObject:c];
	[c release];

	[self renumber];

	[db insertCategory:c];
	return c;
}

-(void)deleteCategoryAtIndex:(int)index
{
	Category *c = [categories objectAtIndex:index];
	[db deleteCategory:c];
	[categories removeObjectAtIndex:index];
}

- (void)reorderCategory:(int)from to:(int)to
{
	Category *c = [[categories objectAtIndex:from] retain];
	[categories removeObjectAtIndex:from];
	[categories insertObject:c atIndex:to];
	[c release];
	
	[self renumber];
}

-(void)renumber
{
	int i, max = [categories count];

	[db beginTransaction];
	for (i = 0; i < max; i++) {
		Category *c = [categories objectAtIndex:i];
		c.sorder = i;
		[db updateCategory:c];
	}
	[db commitTransaction];
}


@end
