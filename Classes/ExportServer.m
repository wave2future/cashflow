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

#import "ExportServer.h"
#import <arpa/inet.h>
#import <unistd.h>

@implementation ExportServer

@synthesize contentBody = mContentBody, contentType = mContentType, filename = mFilename;


#define BUFSZ   4096

- (void)dealloc
{
    [mContentType release];
    [mContentBody release];
    [mFilename release];
    [super dealloc];
}

- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(int)bodylen
{
    const char *p;
    
    // Request to '/' url.
    // Return redirect to target file name.
    if ([filereq isEqualToString:@"/"])
    {
        NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
        p = [outcontent UTF8String];
        write(s, p, strlen(p));
		
        outcontent = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"refresh\" content=\"0;url=%@\"></head></html>", mFilename];
        p = [outcontent UTF8String];
        write(s, p, strlen(p));
		
        return;
    }
		
    // Ad hoc...
    // No need to read request... Just send only one file!
    NSString *content = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", mContentType];
    p = [content UTF8String];
    write(s, p, strlen(p));
	
    int clen = [mContentBody length];
    if (clen > 0) {
        write(s, [mContentBody bytes], clen);
    }

}

@end
