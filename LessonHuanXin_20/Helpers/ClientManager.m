//
//  ClientManager.m
//  LessonHuanXin_20
//
//  Created by SMX on 2016/10/10.
//  Copyright © 2016年 SMX. All rights reserved.
//

#import "ClientManager.h"
#import "EMSDK.h"

@implementation ClientManager
//v3版本的环信.登录、注册、好友添加等操作都是同步任务，我们需要封装成异步任务
+ (ClientManager *)sharedClientManager {
    static ClientManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ClientManager alloc] init];
    });
    return manager;
}

//注册方法
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password completeHandle:(void (^)(EMError *))complete
{
    //1.创建并发队列异步任务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //这个block中的代码.都在子线程中并发执行
        EMError *error = [[EMClient sharedClient] registerWithUsername:userName password:password];
        //获取主线程队列 准备传值和跳转界面
        dispatch_async(dispatch_get_main_queue(), ^{
           //调用block
            complete(error);
        });
        
    });
}

//登录方法
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password completeHandle:(void (^)(EMError *))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:userName password:password];
        //回主线程 刷新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(error);
        });
    });
}

//添加好友
- (void)addContactWithUserName:(NSString *)userName message:(NSString *)message completeHandle:(void (^)(EMError *))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //子线程执行
        //添加好友
        EMError *error = [[EMClient sharedClient].contactManager addContact:userName message:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            complete(error);
        });
    });
}

//删除好友
- (void)deleteContactWithUserName:(NSString *)userName complete:(void (^)(EMError *))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //子线程执行
        //删除好友
        EMError *error = [[EMClient sharedClient].contactManager deleteContact:userName];
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            complete(error);
        });
    });
}

@end
