// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AppDelegate.h"
#import "TransactionListVC.h"
#import "DataModel.h"
#import "Transaction.h"
#import "PinController.h"
#import "CrashReporter.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;

- (id)init {
    if (self = [super init]) {
        // 
    }
    return self;
}

//
// 開始処理
//
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSLog(@"applicationDidFinishLaunching");
    
    PLCrashReporter *cr = [PLCrashReporter sharedReporter];
    if ([cr hasPendingCrashReport]) {
        [self handleCrashReport];
    }
    NSError *error;
    if (![cr enableCrashReporterAndReturnError:&error]) {
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
    }
    
    // Configure and show the window
    if (IS_IPAD) {
        [window addSubview:splitViewController.view];
    } else {
        [window addSubview:[navigationController view]];
    }
    [window makeKeyAndVisible];

    // PIN チェック
    [self checkPin];
    
    NSLog(@"applicationDidFinishLaunching: done");
}

// Background から復帰するときの処理
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkPin];
}

- (void)checkPin
{
    PinController *pinController = [[[PinController alloc] init] autorelease];
    if (IS_IPAD) {
        [pinController firstPinCheck:splitViewController];
    } else {
        [pinController firstPinCheck:navigationController];
    }    
}


//
// 終了処理 : データ保存
//
- (void)applicationWillTerminate:(UIApplication *)application
{
    [DataModel finalize];
    [Database shutdown];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[DataModel finalize];
    //[Database shutdown];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}

//
// Called to handle a pending crash report.
//
- (void) handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        goto finish;
    }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    PLCrashReport *report = [[[PLCrashReport alloc] initWithData: crashData error: &error] autorelease];
    if (report == nil) {
        NSLog(@"Could not parse crash report");
        goto finish;
    }
    
    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
          report.signalInfo.code, report.signalInfo.address);
    
    // Purge the report
finish:
    [crashReporter purgePendingCrashReport];
    return;
}

void AssertFailed(const char *filename, int lineno)
{
    UIAlertView *v = [[UIAlertView alloc]
                         initWithTitle:@"Assertion Failed"
                         message:[NSString stringWithFormat:@"%@ line %d", 
                                  [NSString stringWithCString:filename encoding:NSUTF8StringEncoding] , lineno]
                         delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [v show];
    [v release];
}

@end
