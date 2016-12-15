//
//  ClientManager.h
//  LessonHuanXin_20
//
//  Created by SMX on 2016/10/10.
//  Copyright © 2016年 SMX. All rights reserved.
//

#import <Foundation/Foundation.h>

//引入错入原因的类型
@class EMError;

@interface ClientManager : NSObject

+ (ClientManager *)sharedClientManager;

//封装注册方法
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password completeHandle:(void(^)(EMError *error))complete;


//登录方法
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password completeHandle:(void(^)(EMError *error))complete;

//异步添加好友的方法
- (void)addContactWithUserName:(NSString *)userName message:(NSString *)message completeHandle:(void(^)(EMError *error))complete;

//删除好友
- (void)deleteContactWithUserName:(NSString *)userName complete:(void(^)(EMError *error))complete;


@end
