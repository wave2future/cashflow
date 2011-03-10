// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ExportCsv.h"
#import "ExportOfx.h"

@interface ExportVC : UIViewController {
    IBOutlet UIButton *exportButton;
    IBOutlet UISegmentedControl *formatControl;
    IBOutlet UISegmentedControl *rangeControl;
    IBOutlet UISegmentedControl *methodControl;
    IBOutlet UILabel *formatLabel;
    IBOutlet UILabel *rangeLabel;
    IBOutlet UILabel *methodLabel;

    ExportCsv *csv;
    ExportOfx *ofx;

    Asset *mAsset;
}

@property(nonatomic,assign) Asset *asset;

- (IBAction)doExport;
- (id)initWithAsset:(Asset *)asset;
- (void)doneAction:(id)sender;

@end
