// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdUtil.m
//

// Note:
//   AdSense : size = 320x50

#if FREE_VERSION

#import "AppDelegate.h"
#import "AdUtil.h"

@implementation AdUtil

+ (NSDictionary *)adAttributes
{
    static NSMutableDictionary *md = nil;

    if (md) return md;

    md = [[NSMutableDictionary alloc] init];

    [md setObject:AFMA_CLIENT_ID forKey:kGADAdSenseClientID];
    [md setObject:@"Takuya Murakami" forKey:kGADAdSenseCompanyName];
    [md setObject:@"CashFlow Free" forKey:kGADAdSenseAppName];
    [md setObject:AFMA_APPID forKey:kGADAdSenseApplicationAppleID];
    [md setObject:AFMA_KEYWORDS forKey:kGADAdSenseKeywords];
    [md setObject:[NSNumber numberWithInt:AFMA_IS_TEST] forKey:kGADAdSenseIsTestAdRequest];

    [md setObject:[UIColor whiteColor] forKey:kGADAdSenseAdBackgroundColor];
    //[UIColor colorWithRed:153/255.0 green:169/255.0 blue:190/256.0 alpha:0] forKey:kGADAdSenseAdBackgroundColor];
    //[UIColor colorWithRed:129/255.0 green:149/255.0 blue:175/256.0 alpha:0] forKey:kGADAdSenseAdBackgroundColor];
    //[UIColor darkGrayColor] forKey:kGADAdSenseAdBackgroundColor];

    [md setObject:[UIColor lightGrayColor] forKey:kGADAdSenseAdBorderColor];
         
    [md setObject:[UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:0] forKey:kGADAdSenseAdTextColor];
    [md setObject:[UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:0] forKey:kGADAdSenseAdLinkColor];
    [md setObject:[UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:0] forKey:kGADAdSenseAdURLColor];

    if (!IS_IPAD) {
        [md setObject:[NSArray arrayWithObjects:AFMA_CHANNEL_IDS, nil] forKey:kGADAdSenseChannelIDs];
    } else {
        [md setObject:[NSArray arrayWithObjects:AFMA_CHANNEL_IDS_IPAD, nil] forKey:kGADAdSenseChannelIDs];
    }
    
    return md;
}

@end

#endif // FREE_VERSION
