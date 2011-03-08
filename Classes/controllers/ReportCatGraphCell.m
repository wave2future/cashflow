// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// ReportCatGraphCell.m
//

#import "ReportCatGraphCell.h"

#define CELL_HEIGHT     160   /* iOS, not retina */
#define CIRCLE_GRAPH_SIZE   140      

@implementation GraphEntry
@synthesize value = mValue, title = mTitle;
@end

@implementation ReportCatGraphCell

+ (ReportCatGraphCell *)reportCatGraphCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCatGraphCell";

    ReportCatGraphCell *cell = (ReportCatGraphCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[ReportCatGraphCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

+ (CGFloat)cellHeight
{
    return CELL_HEIGHT;
}

- (void)dealloc
{
    [mGraphEntries release];
    [super dealloc];
}

static int compareGraphEntry(id x, id y, void *context)
{
    GraphEntry *xr = (GraphEntry *)x;
    GraphEntry *yr = (GraphEntry *)y;
	
    if (xr.value == yr.value) {
        return NSOrderedSame;
    }
    if (xr.value > yr.value) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

/**
   レポート設定
*/
- (void)setReport:(ReportEntry*)reportEntry isOutgo:(BOOL)isOutgo
{
    // GraphEntry の配列を作る
    [mGraphEntries release];
    mGraphEntries = [[NSMutableArray alloc] init];

    Categories *categories = [DataModel instance].categories;

    for (CatReport *cr in mReportEntry.catReports) {
        double value;
        if (mIsOutgo && cr.outgo < 0) {
            value = -cr.outgo;
        } else if (mIsIncome && cr.income > 0) {
            value = cr.income;
        } else {
            continue;
        }

        GraphEntry *e = [[[GraphEntry alloc] init] autorelease];
        e.value = value;
        e.title = [categories categoryStringWithKey:cr.catkey];
        [mGraphEntries addObject:e];
    }

    [mGraphEntries sortUsingFunction:compareGraphEntry context:nil];
}

/**
   セル描画
*/
- (void)drawRect:(CGrect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 左上原点にしておく
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    [self _drawCircleGraph:context];
}

/*
  円グラフ描画
*/
- (void)_drawCircleGraph:(CGContextRef)context
{
    /* 中心座標を計算 */
    double width = self.frame.size.width;
    double graph_x = width * 0.25;
    double graph_y = width * 0.25;
    double graph_r = width * 0.25 * 0.8;

    double sum = 0.0, prev = 0.0;
    for (GraphEntry *ge in mGraphEntries) {
        sum += ge.value;

        // context, x, y, R, start rad, end rad, direction
        double start_rad = - PI / 2 + prev / total * 2 * PI;
        double end_rad   = - PI / 2 + sum  / total * 2 * PI;

        // 色設定
        TODO;

        // 円弧の描画
        CGContextAddArc(context, graph_x, graph_y, graph_r, start_rad, end_rad);
        CGContextFillPath(context);

        prev = sum;
    }
}

/*
  凡例描画
*/
- (void)_drawLegend:(CGContextRef)context
{
    double width = self.frame.size.width;
    double x = width * 0.5;
    double y = 0;

    int n = -1;
    for (GraphEntry *ge in mGraphEntries) {
        n++;

        // 色設定
        TODO;
        // CGContextSetRGBStrokeColor(context, ....);
        // CGContextSetRGBFillColor(context, ....);

        // ■を描画
        CGContextAddRect(context, CGRectMake(width * 0.5, n * 10, 8.0, 8.0));
        CGContextStrokePath(context);
                         
        
        
    }

}



@end
