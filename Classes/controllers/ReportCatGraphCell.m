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
    [mCatReports release];
    [super dealloc];
}

/**
   レポート設定
*/
- (void)setReport:(ReportEntry*)reportEntry isOutgo:(BOOL)isOutgo
{
    NSMutableArray *ary;

    if (isOutgo) {
        ary = reportEntry.outgoCatReports;
        mTotal = reportEntry.totalOutgo;
    } else {
        ary = reportEntry.incomeCatReports;
        mTotal = reportEntry.totalIncome;
    }

    if (mCatReports != ary) {
        [mCatReports release];
        mCatReports = ary;
        [mCatReports retain];
    }
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

    // 背景消去
    [[UIColor clearColor] set];
    UIRectFill(rect);

    [self _drawCircleGraph:context];
    [self _drawLegend:context];
}

#define PI 3.14159265358979323846

static inline double radians(double deg)
{
    return deg * PI / 180.0;
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
    double graph_r = width * 0.25 * 0.9;

    double sum = 0.0, prev = 0.0;
    int n = -1;

    for (CatReport *cr in mCatReports) {
        n++;
        sum += ge.value;

        // context, x, y, R, start rad, end rad, direction
        double start_rad = radians(-90 + prev / mTotal * 360);
        double end_rad   = radians(-90 + sum  / mTotal * 360);

        // 色設定
        UIColor *color = [self _getColor:n];
        CGContextSetFillColor(context, CGColorGetComponents([color CGColor]));

        // 円弧の描画
        CGContextMoveToPoint(context, graph_x, graph_y);
        CGContextAddArc(context, graph_x, graph_y, graph_r, start_rad, end_rad, 0);
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
    for (CatReport *cr in mCatReports) {
        n++;

        // 色設定
        UIColor *color = [self _getColor:n];
        CGContextSetFillColor(context, CGColorGetComponents([color CGColor])

        // ■を描画
        CGContextAddRect(context, CGRectMake(width * 0.5, n * 10, 8.0, 8.0));
        CGContextStrokePath(context);
    }

    // 黒のフォント
    UIColor *color = [UIColor blackColor];
    [color set];
    UIFont *font = [UIFont systemFontOfSize:4];
    
    n = -1;
    for (CatReport *cr in mCatReports) {
        n++;

        // 文字を描画
        [[cr title] drawAtPoint:CGPointMake(width * 0.5 + 10, n * 10, font)];
    }
}

/**
   円グラフ用の色を生成する

   ６色毎に G / B / R / G+B / B+R / R+G を回転する。
   １周目は緑⇒青⇒赤⇒シアン⇒マゼンタ⇒黄で開始。
*/
- (UIColor *)_getColor:(int)index
{
    int n = index / 6;

    double c1 = 1.0 - n * 0.2;
    double c2 = n * 0.12;
    double c3 = n * 0.1;

    double r, g, b;

    switch (index % 6) {
    case 0:
        r = c3; b = c2; g = c1;
        break;
    case 1:
        r = c2; b = c1; g = c3;
        break;
    case 2:
        r = c1; b = c3; g = c2;
        break;
    case 3:
        r = c3; b = c1; g = c1;
        break;
    case 4:
        r = c1; b = c1; g = c3;
        break;
    case 5:
        r = c1; b = c3; g = c1;
        break;
    }

    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
