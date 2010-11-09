// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "Report.h"
#import "CurrencyManager.h"

@interface CurrencyManagerTests : IUTTest {
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
    //AssertEqual(s, @"$1,234.56");
    AssertEqual(@"￥1,235", s);
}

- (void)testUSD
{
    [manager setBaseCurrency:@"USD"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    AssertEqual(@"$1,234.56", s);
}

- (void)testJPY
{
    [manager setBaseCurrency:@"JPY"];
    NSString *s = [CurrencyManager formatCurrency:1234];
    //AssertEqual(@"¥1,234", s);
    AssertEqual(@"￥1,234", s);
}

- (void)testEUR
{
    [manager setBaseCurrency:@"EUR"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    AssertEqual(@"€1,234.56", s);
}

- (void)testOther
{
    [manager setBaseCurrency:@"CAD"];
    NSString *s = [CurrencyManager formatCurrency:1234.56];
    AssertEqual(@"CA$1,234.56", s);
}

@end
