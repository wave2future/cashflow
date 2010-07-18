// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "Report.h"
#import "CurrencyManager.h"

@interface CurrencyManagerTests : SenTestCase {
    CurrencyManager *manager;
}
@end

@implementation CurrencyManagerTests

- (void)setUp
{
    manager = [CurrencyManager instance];
}

- (void)tearDown
{
}

- (void) testInit {
    STAssertTrue(manager != nil, @"");
}

- (void)testSystem
{
    [manager setBaseCurrency:nil];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    STAssertTrue([s isEqualToString:@"$1,234.56"], s);
}

- (void)testUSD
{
    [manager setBaseCurrency:@"USD"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    STAssertTrue([s isEqualToString:@"$1,234.56"], s);
}

- (void)testJPY
{
    [manager setBaseCurrency:@"JPY"];
    NSString *s = [CurrencyManager formatCurrency:1234];
    STAssertTrue([s isEqualToString:@"¥1,234"], s);
}

- (void)testEUR
{
    [manager setBaseCurrency:@"EUR"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    STAssertTrue([s isEqualToString:@"€1,234.56"], s);
}

- (void)testOther
{
    [manager setBaseCurrency:@"CAD"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    STAssertTrue([s isEqualToString:@"CA$1,234.56"], s);
}

@end
