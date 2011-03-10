// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "WebServer.h"

@interface ExportServer : WebServer
{
    NSString *mContentType;
    NSData *mContentBody;
    NSString *mFilename;
}

@property(nonatomic,retain) NSString* contentType;
@property(nonatomic,retain) NSData* contentBody;
@property(nonatomic,retain) NSString* filename;

- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(int)bodylen;
@end
