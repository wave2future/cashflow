#import "WebServer.h"
#import <arpa/inet.h>

@implementation WebServer

@synthesize contentBody;

- (BOOL)startServer
{
    int on;
    struct sockaddr_in addr;

    listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_sock < 0) {
        return NO;
    }

    on = 1;
    setsockopt(listen_sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(8080);

    if (bind(listen_sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        close(listen_sock);
        return NO;
    }
	
	socklen_t len = sizeof(serv_addr);
	if (getsockname(listen_sock, (struct sockaddr *)&serv_addr, &len)  < 0) {
		close(listen_sock);
		return NO;
	}

    if (listen(listen_sock, 16) < 0) {
        close(listen_sock);
        return NO;
    }
	
	thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
	[thread start];
	
	return YES;
}

- (void)stopServer
{
	if (listen_sock >= 0) {
		close(listen_sock);
	}
	listen_sock = -1;
}

- (NSString*)serverUrl
{
	int s = socket(AF_INET, SOCK_DGRAM, 0);
	struct sockaddr_in addr;
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(0x01010101); // dummy address
	addr.sin_port = htons(80);
	
	if (connect(s, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
		close(s);
		return nil;
	}
	
	socklen_t len = sizeof(addr);
	getsockname(s, (struct sockaddr*)&addr, &len);
	
	char addrstr[64];
	inet_ntop(AF_INET, (void*)&addr.sin_addr.s_addr, addrstr, sizeof(addrstr));
	NSString *url = [[[NSString alloc] initWithFormat:@"http://%s", addrstr] autorelease];
	return url;
}

- (void)threadMain:(id)dummy
{	
	NSAutoreleasePool *pool;
	pool = [[NSAutoreleasePool alloc] init];
	
	int s;
	socklen_t len;
	struct sockaddr_in caddr;
	
    for (;;) {
        len = sizeof(caddr);
        s = accept(listen_sock, (struct sockaddr *)&caddr, &len);
        if (s < 0) {
			break;
        }

        [self handleHttpRequest:s];

        close(s);
    }

	if (listen_sock >= 0) {
		close(listen_sock);
	}
	listen_sock = -1;
	
	[pool release];
	[NSThread exit];
}

#define BUFSZ   4096

- (void)handleHttpRequest:(int)s
{
    char buf[BUFSZ+1];

    int len = recv(s, buf, sizeof(BUFSZ), 0);
    if (len <= 0) {
        return; 
    }
    buf[len] = '\0'; // null terminate

    // No need to read request... Just send only one file!

    NSString *content = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", contentType];
    send(s, [content UTF8String], [content length], 0);
    send(s, [contentBody UTF8String], [contentBody length], 0);
}

@end

        
