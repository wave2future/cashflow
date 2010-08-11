// Generated by O/R mapper generator ver 0.1(cashflow)

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@interface AssetBase : ORRecord {
    NSString* name;
    int type;
    double initialBalance;
    int sorder;
    double lastBalance;
}

@property(nonatomic,retain) NSString* name;
@property(nonatomic,assign) int type;
@property(nonatomic,assign) double initialBalance;
@property(nonatomic,assign) int sorder;
@property(nonatomic,assign) double lastBalance;

+ (BOOL)migrate;

+ (id)allocator;

// CRUD (Create/Read/Update/Delete) operations

// Create operations
- (void)insert;

// Read operations
+ (AssetBase *)find:(int)pid;
+ (NSMutableArray *)find_cond:(NSString *)cond;
+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (NSMutableArray *)find_stmt:(dbstmt *)cond;

// Update operations
- (void)update;

// Delete operations
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)_loadRow:(dbstmt *)stmt;

@end
