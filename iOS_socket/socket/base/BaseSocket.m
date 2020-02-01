//
//  BaseSocket.m
//  iOS_socket
//
//  Created by hailong on 2020/01/13.
//  Copyright © 2020 HL. All rights reserved.
//

#import "BaseSocket.h"
#import <sys/socket.h>
#import <sys/un.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <unistd.h>

#define MESSAGE_SIZE 10240
#define SERVER_PORT 55667
#define SERVER_ADD  "127.0.0.1"
#define BUFFER_SIZE 1024
#define MAXLINE        100

@implementation BaseSocket

- (void) setupServerTCP;
{
    int listenfd, connfd;
    socklen_t clilen;
    struct sockaddr_in cliaddr, servaddr;
    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(SERVER_PORT);
    
    //端口重用问题
    int on = 1;
    setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
    
    /* bind到本地地址，端口为12345 */
    bind(listenfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
    
    /* listen的backlog为1024 */
    listen(listenfd, 1024);
    
    /* 循环处理用户请求 */
    for (;;) {
        clilen = sizeof(cliaddr);
        connfd = accept(listenfd, (struct sockaddr *) &cliaddr, &clilen);
        [self read:connfd];/* 读取数据 */
        close(connfd);/* 关闭连接套接字，注意不是监听套接字*/
    }
}

- (void) read:(int) sockfd;
{
    ssize_t n;
    char buf[1024];
    int hasRead = 0;
    int time = 0;
    for (;;) {
        fprintf(stdout, "block in read\n");
        if ((n = read(sockfd, buf, 1024)) == 0){
            fprintf(stdout, "read end %s",buf);
            return;
        }
        if (n < 0) {
            buf[hasRead]='\0';
            close(sockfd);
            break;
        }
        hasRead += n;
        time++;
        fprintf(stdout, "1K read for %d \n", time);
        usleep(1000);
    }
    
    NSLog(@"buf = %s",buf);
}


#pragma mark -

- (void) setupClinetTCP;
{
    int sockfd;
    struct sockaddr_in servaddr;
    
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(SERVER_PORT);
    
    //    inet_pton(AF_INET, "192.168.50.91", &servaddr.sin_addr);
    inet_pton(AF_INET, SERVER_ADD, &servaddr.sin_addr);
    
    int connect_rt = connect(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
    if (connect_rt < 0) {
        NSLog(@"connect failed ");
    }
    [self sendData:sockfd];
    
    [self read:sockfd];
}

- (void)sendData:(int) sockfd
{
    char *query;
    query = malloc(MESSAGE_SIZE + 1);
    for (int i = 0; i < MESSAGE_SIZE; i++){
        query[i] = 'a';
        if (i > 10 && i < 14) {
            query[i] = 'b';
        }
    }
    
    query[MESSAGE_SIZE] = '\0';
    
    const char *cp;
    cp = query;
    size_t remaining = strlen(query);
    while (remaining) {
        ssize_t n_written = send(sockfd, cp, remaining, 0);
        NSLog(@"send into buffer %ld \n", n_written);
        if (n_written <= 0) {
            NSLog(@"send failed");
            return;
            
        }
        remaining -= n_written;
        cp += n_written;
        
    }
}


- (void) setupServerUDP;
{
    int socket_fd;
    socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_port = htons(SERVER_PORT);
    bind(socket_fd, (struct sockaddr *) &server_addr, sizeof(server_addr));
    
    socklen_t client_len;
    char message[MESSAGE_SIZE];
    int count = 0;
    struct sockaddr_in client_addr;
    client_len = sizeof(client_addr);
    for (;;) {
        ssize_t n = recvfrom(socket_fd, message, MESSAGE_SIZE, 0, (struct sockaddr *) &client_addr, &client_len);
        message[n] = 0;
        printf("received %ld bytes: %s\n", n, message);
        char send_line[MESSAGE_SIZE];
        sprintf(send_line, "Hi, %s", message);
        sendto(socket_fd, send_line, strlen(send_line), 0, (struct sockaddr *) &client_addr, client_len); count++;
    }
}

- (void) setupClinetUDP;
{
    int socket_fd;
    socket_fd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    inet_pton(AF_INET, SERVER_ADD, &server_addr.sin_addr);
    socklen_t server_len = sizeof(server_addr);
    struct sockaddr *reply_addr;
    reply_addr = malloc(server_len);
    char send_line[MESSAGE_SIZE], recv_line[MESSAGE_SIZE + 1];
    socklen_t len;
    ssize_t n;
    
    strcpy(send_line, "aa,hahah");
    size_t rt = sendto(socket_fd, send_line, strlen(send_line), 0, (struct sockaddr *) &server_addr, server_len);
    if (rt < 0) {
    }
    printf("CC send bytes: %zu \n", rt);
    len = 0;
    n = recvfrom(socket_fd, recv_line, MESSAGE_SIZE, 0, reply_addr, &len);
    if (n < 0) NSLog(@"recvfrom failed");
    recv_line[n] = 0;
    
    printf("CC received %s", recv_line);
}

- (NSString *) localFile;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*docpath=[paths objectAtIndex:0];
    NSString * path = [docpath stringByAppendingPathComponent:@"t"];
    return path = @"/Users/hailong/thl.ipc";
}


- (void) setupServerLocalIPCStream;
{
    NSString * path = [self localFile];
    
    int listenfd, connfd;
    socklen_t clilen;
    struct sockaddr_un cliaddr, servaddr;
    
    listenfd = socket(AF_LOCAL, SOCK_STREAM, 0);
    
    unlink([path UTF8String]);
    bzero(&servaddr, sizeof(servaddr));
    
    servaddr.sun_family = AF_LOCAL;
    strcpy(servaddr.sun_path, [path UTF8String]);
    
    if (bind(listenfd, (struct sockaddr *) &servaddr, sizeof(servaddr)) < 0) {
        NSLog(@"bind failed");
    }
    
    /* listen的backlog为1024 */
    listen(listenfd, 1024);
    
    clilen = sizeof(cliaddr);
    if ((connfd = accept(listenfd, (struct sockaddr *) &cliaddr, &clilen)) < 0) {
        if (errno == EINTR)
            NSLog(@"accept failed"); /* back to for() */
        else
            NSLog(@"accept failed");
    }
    
    char buf[BUFFER_SIZE];
    while (1) {
        bzero(buf, sizeof(buf));
        if (read(connfd, buf, BUFFER_SIZE) == 0) {
            printf("client quit");
            break;
        }
        NSLog(@"SS Receive: %s", buf);
        char send_line[MAXLINE];
        sprintf(send_line, "Hi, %s", buf);
        int nbytes = sizeof(send_line);
        if (write(connfd, send_line, nbytes) != nbytes)
            NSLog(@"write error");
        
    }
    
    close(listenfd);
    close(connfd);
}

- (void) setupClinetLocalIPCStream;
{
    NSString * path = [self localFile];
    
    int sockfd;
    struct sockaddr_un servaddr;
    sockfd = socket(AF_LOCAL, SOCK_STREAM, 0);
    if (sockfd < 0) {
        NSLog(@"create socket failed");
    }
    
    bzero(&servaddr, sizeof(servaddr));
    servaddr.sun_family = AF_LOCAL;
    strcpy(servaddr.sun_path, [path UTF8String]);
    
    if (connect(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr)) < 0) {
        NSLog(@"connect failed");
    }
    
    char send_line[MAXLINE];
    bzero(send_line, MAXLINE);
    char recv_line[MAXLINE];
    
    strcpy(send_line, "haha,localIPC");
    int nbytes = sizeof(send_line);
    if (write(sockfd, send_line, nbytes) != nbytes)
        NSLog(@"write error");
    if (read(sockfd, recv_line, MAXLINE) == 0)
        NSLog(@"server terminated prematurely");
    NSLog(@"CC %s",recv_line);
    
    close(sockfd);
}

- (void) setupServerLocalIPCDgram;
{
    NSString * path = [self localFile];
    
    int socket_fd;
    struct sockaddr_un servaddr;
    
    socket_fd = socket(AF_LOCAL, SOCK_DGRAM, 0);
    
    unlink([path UTF8String]);
    bzero(&servaddr, sizeof(servaddr));
    
    servaddr.sun_family = AF_LOCAL;
    strcpy(servaddr.sun_path, [path UTF8String]);
    
    if (bind(socket_fd, (struct sockaddr *) &servaddr, sizeof(servaddr)) < 0) {
        NSLog(@"bind failed");
    }
    
    socklen_t client_len;
    char message[MESSAGE_SIZE];
    int count = 0;
    struct sockaddr_in client_addr;
    client_len = sizeof(client_addr);
    for (;;) {
        ssize_t n = recvfrom(socket_fd, message, MESSAGE_SIZE, 0, (struct sockaddr *) &client_addr, &client_len);
        message[n] = 0;
        printf("received %ld bytes: %s\n", n, message);
        char send_line[MESSAGE_SIZE];
        sprintf(send_line, "Hi, %s", message);
        sendto(socket_fd, send_line, strlen(send_line), 0, (struct sockaddr *) &client_addr, client_len); count++;
    }
    
}


- (NSString *) localFileUDP;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*docpath=[paths objectAtIndex:0];
    NSString * path = [docpath stringByAppendingPathComponent:@"t"];
    return path = @"/Users/hailong/thl.ipc";
}
- (void) setupClinetLocalIPCDgram;
{
     NSString * path = [self localFile];
    NSString * clinetpath = [self localFileUDP];
    unlink([path UTF8String]);
    unlink([clinetpath UTF8String]);
    
    
    int socket_fd;
    struct sockaddr_un client_addr, server_addr;
    
    socket_fd = socket(AF_LOCAL, SOCK_DGRAM, 0);
    
    bzero(&client_addr, sizeof(client_addr));
    client_addr.sun_family = AF_LOCAL;
    strcpy(client_addr.sun_path, [clinetpath UTF8String]);
    
    if (bind(socket_fd, (struct sockaddr *) &client_addr, sizeof(client_addr)) < 0) {
        NSLog(@"bind failed");
    }
    
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sun_family = AF_LOCAL;
    strcpy(server_addr.sun_path, [path UTF8String]);
    
    char send_line[MAXLINE];
    bzero(send_line, MAXLINE);
    char recv_line[MAXLINE];
    strcpy(send_line, "aa,hahah");
    
    size_t nbytes = strlen(send_line);
    printf("now sending %s \n", send_line);
    
    if(sendto(socket_fd, send_line, strlen(send_line), 0, (struct sockaddr *) &server_addr, sizeof(server_addr)) != nbytes){
       NSLog(@"ERROR CC send");
    }
    
    ssize_t n = recvfrom(socket_fd, recv_line, MESSAGE_SIZE, 0, NULL, NULL);
    if (n < 0) NSLog(@"recvfrom failed");
    recv_line[n] = 0;
    
    printf("CC received %s", recv_line);
}
@end
