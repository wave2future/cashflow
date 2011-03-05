// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "ReporEntry.h"

@interface ReportTest : IUTTest {
    Report *reports;
}
@end

@implementation ReportTest

- (void)setUp
{
    [TestCommon installDatabase:@"testdata1"];
    [DataModel instance];
    
    reports = [[Report alloc] init];
}

- (void)tearDown
{
    [reports release];
}

- (void)testMonthly
{
    [reports generate:REPORT_MONTHLY asset:nil];

    AssertEqualInt(1, [reports.reports count]);
    ReporEntry *report = [reports.reports objectAtIndex:0];

    //NSString *s = [TestCommon stringWithDate:report.date];
    //Assert([s isEqualToString:@"200901010000"]);
    AssertEqualDouble(100000, report.totalIncome);
    AssertEqualDouble(-3100, report.totalOutgo);
}


@end
