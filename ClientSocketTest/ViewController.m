//
//  ViewController.m
//  ClientSocketTest
//
//  Created by myxc on 31/05/2018.
//  Copyright © 2018 myxc. All rights reserved.
//

#import "ViewController.h"
#import <arpa/inet.h>
#import <sys/socket.h>

@interface ViewController () {
    int _clientSocket;//nc -lk 1024
}
@property (weak, nonatomic) IBOutlet UITextField *textFild;
@property (nonatomic, strong) NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self connect:nil];
}

//建立连接
- (void)connectToServer:(NSString *)ip port:(int)port {
    
//    NSString *ip = @"127.0.0.1";
//    int port = [@"5288" intValue];
//    [self connectToServer:ip port:port];
    _clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    struct sockaddr_in addr;
    /* 填写sockaddr_in结构*/
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip.UTF8String);
    
    int connectResult = connect(_clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connectResult == 0) {
        NSLog(@"conn ok");

    }else{
        NSLog(@"conn failed");
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if (_clientSocket != 0) {
        [self sentAndRecv:self.textFild.text];

    } else {
        NSLog(@"已与服务器断开链接");
    }

}

//发送数据并等待返回数据
- (void)sentAndRecv:(NSString *)msg {
    dispatch_queue_t q_con =  dispatch_queue_create("CONCURRENT", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(q_con, ^{
        const char *str = msg.UTF8String;
        ssize_t sendLen = send(_clientSocket, str, strlen(str), 0);
        
        NSLog(@"sendLen : %zd",sendLen);
        
//        char *buf[1024];
//        ssize_t recvLen = recv(_clientSocket, buf, sizeof(buf), 0);
//        NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"recvStr : %@",recvStr);
//        });
    });
    
}
- (IBAction)connect:(id)sender {
    static const char *ip = "127.0.0.1";
    static const int port = 5288;
    struct sockaddr_in addr;
    _clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip);
    
    int connecResult = connect(_clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connecResult == 0) {
        NSLog(@"connect ok");
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveAction) object:nil];
        [self.thread start];
    } else {
        NSLog(@"connect failed");
        [self.thread cancel];
    }
    
}


- (void)receiveAction{
    while (1) {
        char *buf[1024];
        ssize_t recvLen = recv(_clientSocket, buf, sizeof(buf), 0);
        NSString *recvStr = [[NSString alloc] initWithBytes:buf length:recvLen encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"recvStr : %@",recvStr);
        });
    }
}

- (IBAction)shutdown:(id)sender {
    
    shutdown(_clientSocket, SHUT_RDWR);
    close(_clientSocket);
}


@end
