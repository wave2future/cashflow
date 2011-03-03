// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  O/R Mapper library for iPhone

  Copyright (c) 2010, Takuya Murakami. All rights reserved.

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

#import "AppDelegate.h"
#import "DateFormatter2.h"
#import "Database.h"

@implementation CashflowDatabase

@synthesize needFixDateFormat;

/**
   Return the database instance (singleton)
*/
+ (void)initialize
{
    CashflowDatabase *db = [[CashflowDatabase alloc] init];
    [super setSingletonInstance:db];
}

- (id)init
{
    self = [super init];
    
    needFixDateFormat = false;
	
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat: @"yyyyMMddHHmmss"];
    
    // Set US locale, because JP locale for date formatter is buggy,
    // especially for 12 hour settings.
    NSLocale *us = [[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease];
    [dateFormatter setLocale:us];

    // backward compat.
    dateFormatter2 = [[DateFormatter2 alloc] init];
    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter2 setDateFormat: @"yyyyMMddHHmm"];
    
    // for broken data...
    dateFormatter3 = [[DateFormatter2 alloc] init];
    [dateFormatter3 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter3 setDateFormat: @"yyyyMMdd"];
    
    return self;
}

- (void)dealloc
{
    [dateFormatter release];
    [super dealloc];
}

#pragma mark -
#pragma mark Utilities

- (NSDate *)dateFromString:(NSString *)str
{
    NSDate *date = nil;
    
    if ([str length] == 14) { // yyyyMMddHHmmss
        date = [dateFormatter dateFromString:str];
    }
    if (date == nil) {
        // backward compat.
        needFixDateFormat = true;
        date = [dateFormatter2 dateFromString:str];

        if (date == nil) {
            date = [dateFormatter3 dateFromString:str];
        }
        if (date == nil) {
            date = [dateFormatter dateFromString:@"20000101000000"]; // fallback
        }
    }
    return date;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

@end
