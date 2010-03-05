// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

// Note:
//   AdSense : size = 320x50

#if FREE_VERSION

#import "AdCell.h"

/////////////////////////////////////////////////////////////////////
// AdCell

@implementation AdCell

+ (CGFloat)adCellHeight
{
    return 50; // AdSense
}

+ (AdCell *)adCell:(UITableView *)tableView viewController:(UIViewController *)parentViewController
{
    NSString *identifier = @"AdCell";

    AdCell *cell = (AdCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[AdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    cell.parentViewController = parentViewController;

    return cell;
}

- (UITableViewCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];

    // 広告を作成する
    adViewController= [[GADAdViewController alloc] initWithDelegate:self];
    adViewController.adSize = kGADAdSize320x50;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"ca-mb-app-pub-4621925249922081", kGADAdSenseClientID,
                                @"Takuya Murakami", kGADAdSenseCompanyName,
                                @"CashFlow Free", kGADAdSenseAppName,
                                //@"ファイナンス,家計簿,金融,キャッシュ,キャッシング,finance,cash,money", kGADAdSenseKeywords,
                                //@"クレジット+カード,銀行,ファイナンス,キャッシュ,finance,cash,money", kGADAdSenseKeywords,
                                @"マネー,ファイナンス,銀行,預金,キャッシュ,クレジット,money,finance,bank,cash,credit", kGADAdSenseKeywords,
                                [NSArray arrayWithObjects:@"9215174282", nil], kGADAdSenseChannelIDs,
                                [NSNumber numberWithInt:1], kGADAdSenseIsTestAdRequest,
                                //[UIColor colorWithRed:129/255.0 green:149/255.0 blue:175/256.0 alpha:0], kGADAdSenseAdBackgroundColor,
                                nil];
    
    [adViewController loadGoogleAd:attributes];
    UIView *adView = adViewController.view;
    [self.contentView addSubview:adView];

    return self;
}

- (void)dealloc {
    [adViewController release];
    [super dealloc];
}

#pragma mark GADAdViewControllerDelegate

- (UIViewController *)viewControllerForModalPresentation:(GADAdViewController *)adController
{
    return parentViewController;
}

- (GADAdClickAction)adControllerActionModelForAdClick:(GADAdViewController *)adController
{
    return GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW;
}

#endif // FREE_VERSION

@end
