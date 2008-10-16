- (BOOL)startServer
{
    int s;
    int len, on;
    struct sockaddr_in addr, caddr;

    listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_sock < 0) {
        return NO;
    }

    on = 1;
    setsockopt(listen_sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = 80; // HTTP

    if (bind(listen_sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        close(listen_sock);
        return NO;
    }

    if (listen(listen_sock, 16) < 0) {
        close(listen_sock);
        return NO;
    }

    for (;;) {
        len = sizeof(caddr);
        s = accept(listen_sock, (struct sockaddr *)&caddr, &len);
        if (s < 0) {
            close(listen_sock);
            return NO;
        }

        [self handleHttpRequest:s];

        close(s);
    }

    return YES;
}

- (void)stopServer
{
    close(listen_sock);
}

#define BUFSZ   4096

- (void)handleHttpRequest:(int)s
{
    char buf[BUFSZ+1];

    int len = recv(s, buf, sizeof(BUFSZ));
    if (len <= 0) {
        return; 
    }
    buf[len] = '\0'; // null terminate

    // No need to read request... Just send only one file!

    NSString *content = [NSString stringWithFormat:
                                      @"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", contentType];
    send(s, [content UTF8String], [content length]);
    send(s, [contentBody UTF8String], [contentBody length]);
}
        
