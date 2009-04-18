// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>
#import "TestCommon.h"

@implementation TestCommon

+ (DateFormatter2 *)dateFormatter
{
    static DateFormatter2 *df = nil;
    if (df == nil) {
        df = [[DateFormatter2 alloc] init];
        [df setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat: @"yyyyMMddHHmm"];
    }
    return df;
}

+ (NSDate *)dateWithString:(NSString *)s
{
    return [[TestCommon dateFormatter] dateFromString:s];
}

+ (NSString *)stringWithDate:(NSDate *)date
{
    return [[TestCommon dateFormatter] stringFromDate:date];
}

// データベースを削除する
+ (void)deleteDatabase
{
    [DataModel finalize];
    [Database shutdown];

    NSString *dbPath = [Database dataFilePath];

    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:NULL];
}

// データベースをインストールする
+ (void)installDatabase:(NSString *)sqlFileName
{
    [TestCommon deleteDatabase];

    NSString *sqlPath = [[NSBundle mainBundle] pathForResource:sqlFileName ofType:@"sql"];
    NSString *dbPath = [Database dataFilePath];

    // load sql
    NSData *data = [NSData dataWithContentsOfFile:sqlPath];
    char *sql = malloc([data length] + 1);
    [data getBytes:sql];
    sql[[data length]] = '\0'; // null terminate

    sqlite3 *handle;
    if (sqlite3_open([dbPath UTF8String], &handle) != 0) {
        NSLog(@"sqlite3_open failed!");
        // ### ASSERT?
        return;
    }
    
    if (sqlite3_exec(handle, sql, NULL, NULL, NULL) != SQLITE_OK) {
        NSLog(@"sqlite3_exec failed");
        // ### ASSERT?
    }
    
    sqlite3_close(handle);

    free(sql);
}

@end
