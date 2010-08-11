// Generated by O/R mapper generator ver 0.1(cashflow)

#import "Database.h"
#import "AssetBase.h"

@implementation AssetBase

@synthesize name;
@synthesize type;
@synthesize initialBalance;
@synthesize sorder;
@synthesize lastBalance;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [name release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"name", @"TEXT",
        @"type", @"INTEGER",
        @"initialBalance", @"REAL",
        @"sorder", @"INTEGER",
        @"lastBalance", @"REAL",
        nil];

    return [super migrate:columnTypes];
}

/**
  @brief allocate entry
*/
+ (id)allocator
{
    id e = [[[AssetBase alloc] init] autorelease];
    return e;
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (AssetBase *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Assets WHERE key = ?;"];
    [stmt bindInt:0 val:pid];
    if ([stmt step] != SQLITE_ROW) {
        return nil;
    }

    AssetBase *e = [self allocator];
    [e _loadRow:stmt];
 
    return e;
}

/**
  @brief get all records matche the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (NSMutableArray *)find_cond:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    NSMutableArray *array = [self find_stmt:stmt];
    return array;
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (dbstmt *)gen_stmt:(NSString *)cond
{
    NSString *sql;
    if (cond == nil) {
        sql = @"SELECT * FROM Assets;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM Assets %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  @brief get all records matche the conditions

  @param stmt Statement
  @return array of records
*/
+ (NSMutableArray *)find_stmt:(dbstmt *)stmt
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        AssetBase *e = [self allocator];
        [e _loadRow:stmt];
        [array addObject:e];
    }
    return array;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.name = [stmt colString:1];
    self.type = [stmt colInt:2];
    self.initialBalance = [stmt colDouble:3];
    self.sorder = [stmt colInt:4];
    self.lastBalance = [stmt colDouble:5];

    isInserted = YES;
}

#pragma mark Create operations

- (void)insert
{
    [super insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    [db beginTransaction];
    stmt = [db prepare:@"INSERT INTO Assets VALUES(NULL,?,?,?,?,?);"];

    [stmt bindString:0 val:name];
    [stmt bindInt:1 val:type];
    [stmt bindDouble:2 val:initialBalance];
    [stmt bindInt:3 val:sorder];
    [stmt bindDouble:4 val:lastBalance];
    [stmt step];

    self.pid = [db lastInsertRowId];

    [db commitTransaction];
    isInserted = YES;
}

#pragma mark Update operations

- (void)update
{
    [super update];

    Database *db = [Database instance];
    [db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE Assets SET "
        "name = ?"
        ",type = ?"
        ",initialBalance = ?"
        ",sorder = ?"
        ",lastBalance = ?"
        " WHERE key = ?;"];
    [stmt bindString:0 val:name];
    [stmt bindInt:1 val:type];
    [stmt bindDouble:2 val:initialBalance];
    [stmt bindInt:3 val:sorder];
    [stmt bindDouble:4 val:lastBalance];
    [stmt bindInt:5 val:pid];

    [stmt step];
    [db commitTransaction];
}

#pragma mark Delete operations

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM Assets WHERE key = ?;"];
    [stmt bindInt:0 val:pid];
    [stmt step];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Assets %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [AssetBase delete_cond:nil];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"Assets";
}

@end
