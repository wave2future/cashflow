// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdUtil.m
//

// Note:
//   AdSense : size = 320x50

#if FREE_VERSION

#import "AdUtil.h"

@implementation AdUtil

+ (NSDictionary *)adAttributes
{
    NSDictionary *attributes = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         AFMA_CLIENT_ID, kGADAdSenseClientID,
         @"Takuya Murakami", kGADAdSenseCompanyName,
         @"CashFlow Free", kGADAdSenseAppName,
         AFMA_APPID, kGADAdSenseApplicationAppleID,
         AFMA_KEYWORDS, kGADAdSenseKeywords,
         [NSNumber numberWithInt:AFMA_IS_TEST], kGADAdSenseIsTestAdRequest,

         [UIColor whiteColor], kGADAdSenseAdBackgroundColor,
         //[UIColor colorWithRed:153/255.0 green:169/255.0 blue:190/256.0 alpha:0], kGADAdSenseAdBackgroundColor,
         //[UIColor colorWithRed:129/255.0 green:149/255.0 blue:175/256.0 alpha:0], kGADAdSenseAdBackgroundColor,
         //[UIColor darkGrayColor], kGADAdSenseAdBackgroundColor,

         [UIColor lightGrayColor], kGADAdSenseAdBorderColor,
         
         [UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:0], kGADAdSenseAdTextColor,
         [UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:0], kGADAdSenseAdLinkColor,
         [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:0], kGADAdSenseAdURLColor,
         nil];

    NSMutableDictionary *md = [[[NSMutableDictionary alloc] init] autorelease];
    [md setDictionary:attributes];
    
    if (!IS_IPAD) {
        [md setObject:[NSArray arrayWithObjects:AFMA_CHANNEL_IDS, nil] forKey:kGADAdSenseChannelIDs];
    } else {
        [md setObject:[NSArray arrayWithObjects:AFMA_CHANNEL_IDS_IPAD, nil] forKey:kGADAdSenseChannelIDs];
    }

    return md;
}

@end

#endif // FREE_VERSION
