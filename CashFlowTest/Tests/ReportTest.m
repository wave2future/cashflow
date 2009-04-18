// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "Report.h"

@interface ReportTest : IUTTest {
    Reports *reports;
}
@end

@implementation ReportTest

- (void)setUp
{
    [super setUp];
    [TestCommon installDatabase:@"testdata1"];
    [DataModel instance];
    
    reports = [[Reports alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    [reports release];
}

- (void)testMonthly
{
    [reports generate:REPORT_MONTHLY asset:nil];

    ASSERT_EQUAL_INT(1, [reports.reports count]);
    Report *report = [reports.reports objectAtIndex:0];

    //NSString *s = [TestCommon stringWithDate:report.date];
    //ASSERT([s isEqualToString:@"200901010000"]);
    ASSERT_EQUAL_DOUBLE(100000, report.totalIncome);
    ASSERT_EQUAL_DOUBLE(-3100, report.totalOutgo);
}


@end
