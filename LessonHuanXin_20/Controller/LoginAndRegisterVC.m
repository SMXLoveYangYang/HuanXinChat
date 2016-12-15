//
//  LoginAndRegisterVC.m
//  LessonHuanXin_20
//
//  Created by SMX on 2016/10/10.
//  Copyright © 2016年 SMX. All rights reserved.
//

#import "LoginAndRegisterVC.h"

#import "EMSDK.h"
#import "ClientManager.h"

@interface LoginAndRegisterVC ()<EMClientDelegate>
//EMClientDelegate 为了自动登录功能

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;

@property (weak, nonatomic) IBOutlet UITextField *passwdTF;

@end

@implementation LoginAndRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理对象 --- 自动登录功能
    [[EMClient sharedClient] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    
}

//登录按钮
- (IBAction)loginAction:(UIButton *)sender {
    //是否设置了自动登录功能
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (!isAutoLogin) {
        //调用方法 手动登录
        [[ClientManager sharedClientManager] loginWithUserName:self.userNameTF.text password:self.passwdTF.text completeHandle:^(EMError *error) {
            if (error == nil) {
                NSLog(@"登录成功");
                //设置自动登录
                [EMClient sharedClient].options.isAutoLogin = YES;
                //跳转界面
                [self performSegueWithIdentifier:@"friend" sender:nil];
            }else {
                NSLog(@"登录失败");
            }
        }];
    }
}

//注册按钮
- (IBAction)registerAction:(UIButton *)sender {
    [[ClientManager sharedClientManager] registerWithUserName:self.userNameTF.text password:self.passwdTF.text completeHandle:^(EMError *error) {
        if (error == nil) {
            NSLog(@"注册成功");
        }else {
            NSLog(@"注册失败");
        }
    }];
}

#pragma mark --- EMClient的回调方法
//监听自动登录状态的方法
- (void)autoLoginDidCompleteWithError:(EMError *)aError
{
    if (aError == nil) {
        NSLog(@"自动登录");
        [self performSegueWithIdentifier:@"friend" sender:nil];
    }else {
        NSLog(@"自动登录失败:%@", aError);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
