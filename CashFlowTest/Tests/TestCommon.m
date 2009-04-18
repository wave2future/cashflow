// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>
#import "TestCommon.h"

@implementation TestCommon

+ (NSDate *)dateWithString:(NSString *)s
{
    static DateFormatter2 *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[DateFormatter2 alloc] init];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat: @"yyyyMMddHHmm"];
    }
    return [dateFormatter dateFromString:s];
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
