// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

// Note:
//   AdMob : size = 320x48
//   TG ad : size = 320x60

#import "AdCell.h"

@implementation AdMobDelegate

+ (AdMobDelegate*)getInstance
{
    static AdMobDelegate *theInstance = nil;
    if (theInstance == nil) {
        theInstance = [[AdMobDelegate alloc] init];
    }
    return theInstance;
}

- (NSString*)publisherId
{
    return ADMOB_ID;
}

- (BOOL)useTestAd {
    return NO;
    //return YES;
}

- (void)didReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob:didReceiveAd");
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob:didFailToReceiveAd");
}

@end

/////////////////////////////////////////////////////////////////////
// AdCell

@implementation AdCell

+ (BOOL)_isJaAd
{
    return NO; // force debug admob
    
    static NSString *plang = nil;
    static BOOL isJa = YES;

    if (plang == nil) {
        plang = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([plang isEqualToString:@"ja"]) {
            isJa = YES;
        } else {
            isJa = NO;
        }
    }

    return isJa;
}

+ (CGFloat)adCellHeight
{
    if ([AdCell _isJaAd]) {
        return 60; // TG ad
    }
    return 48; // admob
}

+ (UIView *)adView
{
    static UIView *adView = nil;
    
    if (adView == nil) {
        NSLog(@"adView start load");
        if ([AdCell _isJaAd]) {
            // TG ad
            TGAView *tgad = [TGAView requestWithKey:TGAD_ID Position:0];
            adView = tgad;
        } else {
            // AdMob
            AdMobDelegate *amd = [AdMobDelegate getInstance];
            AdMobView *admob = [AdMobView requestAdWithDelegate:amd];
            adView = admob;
        }
        NSLog(@"adView load finish");
        [adView retain];
    }
    return adView;
}

+ (AdCell *)adCell:(UITableView *)tableView
{
    NSString *identifier = @"AdCell";

    AdCell *cell = (AdCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[AdCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (UITableViewCell *)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame reuseIdentifier:identifier];
    self.text = @"Advertisement Space...";
    self.textColor = [UIColor lightGrayColor];
    self.textAlignment = UITextAlignmentCenter;

    UIView *adView = [AdCell adView];
    [self.contentView addSubview:adView];
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
