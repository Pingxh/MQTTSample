//
//  ViewController.m
//  MQTTSample
//
//  Created by zhoujian on 2018/9/29.
//  Copyright © 2018 zhoujian. All rights reserved.
//

#import "ViewController.h"
#import <MQTTClient.h>
#import <MQTTSessionManager.h>

@interface ViewController ()<MQTTSessionDelegate>
{
    MQTTSession *_session;
}

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = @"192.168.10.82";
    transport.port = 1883;
    
    _session = [[MQTTSession alloc] init];
     _session.delegate = self;
    _session.transport = transport;
    [_session setUserName:@"admin"];
    [_session setPassword:@"admin"];
    
    [_session connectAndWaitTimeout:2];//服务器超时时间，一般不要太长
    
    [_session subscribeToTopic:@"IM/zhou/#" atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
    }];
    
    [_session subscribeToTopic:@"IM/zhoujian/#" atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
        }
    }];

    [_session addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionOld context:nil];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    switch (_session.status) {
            case MQTTSessionManagerStateClosed:
            NSLog(@"连接已经关闭");
            break;
            case MQTTSessionManagerStateClosing:
            NSLog(@"连接正在关闭");
            
            break;
            case MQTTSessionManagerStateConnected:
            NSLog(@"已经连接");
            
            break;
            case MQTTSessionManagerStateConnecting:
            NSLog(@"正在连接中");
            
            break;
            case MQTTSessionManagerStateError:
        
            break;
            case MQTTSessionManagerStateStarting:
            NSLog(@"开始连接");
            break;
        default:
            break;
    }
}

// 接收到新的消息后的回调,接受到服务器的消息后会回调这个代理方法
- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid
{
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"===================================%@",str);
}

- (void)sending:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data
{
    
    
}

- (void)received:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data
{
    NSLog(@"data - %@",data);
    
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"aString - %@", aString);
}

- (IBAction)addFriend:(id)sender
{
    NSString *topic = [NSString stringWithFormat:@"IM/%@/Inbox/add/zhoujian/res", _userNameTextField.text];
    
    [_session publishData:[@"加个好友" dataUsingEncoding:NSUTF8StringEncoding]
                  onTopic:topic
                   retain:nil
                      qos:MQTTQosLevelExactlyOnce];
}

- (IBAction)sendMessage:(id)sender
{
    NSString *topic = [NSString stringWithFormat:@"IM/%@/Friends/#", _userNameTextField.text];
    
    [_session publishData:[@"发个消息" dataUsingEncoding:NSUTF8StringEncoding]
                  onTopic:topic
                   retain:nil
                      qos:MQTTQosLevelExactlyOnce];
    
}

/**
 连接成功的回调

 @param session
 */
- (void)connected:(MQTTSession *)session
{
    
    NSLog(@"连接成功");
}

@end
