//
//  FriendListTVC.m
//  LessonHuanXin_20
//
//  Created by SMX on 2016/10/10.
//  Copyright © 2016年 SMX. All rights reserved.
//

#import "FriendListTVC.h"

#import "ClientManager.h"
#import "EMSDK.h"
#import "ChatTVC.h"

@interface FriendListTVC ()<EMContactManagerDelegate>
//EMContactManagerDelegate 为了接收好友的消息

@property (nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation FriendListTVC

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.设置代理对象
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //2.检索服务器上的好友
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //子线程执行
        EMError *error = nil;
        NSArray *array = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            if (error == nil) {
                //将获取的好友放入数据源数组中
                [self.dataArray addObjectsFromArray:array];
                //刷新界面 表视图
                [self.tableView reloadData];
            }
        });
    });
}

#pragma mark --- 退出登录
- (IBAction)logoutAction:(UIBarButtonItem *)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //子线程执行
        //调用退出登录的方法
        EMError *error = [[EMClient sharedClient] logout:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            if (error == nil) {
                NSLog(@"退出登录成功");
                //返回上一界面
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                NSLog(@"退出登录失败:%@", error);
            }
        });
    });
}

#pragma mark --- 添加好友
- (IBAction)addFriendAction:(UIBarButtonItem *)sender {
    
    //提示框
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: @"提示" message: @"添加好友"  preferredStyle:UIAlertControllerStyleAlert];
    //添加两个输入框
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
       textField.placeholder = @"请输入用户名";
    }];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
       textField.placeholder = @"附加信息";
    }];
    
    //取消添加事件
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    //添加事件
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //1.获取输入框信息
        UITextField *nameTF = alertVC.textFields.firstObject;
        UITextField *messageTF = alertVC.textFields[1];
        //2.发送请求
        [[ClientManager sharedClientManager] addContactWithUserName:nameTF.text message:messageTF.text completeHandle:^(EMError *error) {
            if (error == nil) {
                NSLog(@"请求发送成功");
            }else {
                NSLog(@"请求发送失败");
            }
        }];
    }];
    //将事件给控制器
    [alertVC addAction:acceptAction];
    [alertVC addAction:rejectAction];
    //最后弹出提示框
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    
    
    
}

#pragma mark --- 代理方法
//收到好友的添加请求
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage
{
    //提示框
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: @"好友添加请求" message: [NSString stringWithFormat:@"%@想要添加您为好友, 附加信息:%@", aUsername, aMessage]  preferredStyle:UIAlertControllerStyleAlert];
    //取消
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //注意注意！！！向服务器发送拒绝
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //子线程执行
            EMError *error = [[EMClient sharedClient].contactManager declineInvitationForUsername:aUsername];
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程执行
                if (error == nil) {
                    NSLog(@"拒绝成功");
                }else {
                    NSLog(@"拒绝失败");
                }
            });
        });
        
    }];
    //接受
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //告诉服务器添加好友
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //子线程执行
            EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:aUsername];
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程执行
                if (error == nil) {
                    NSLog(@"接受功能");
                    //注意：双方已经是好友关系，应该把对方显示在表视图好友列表中
                    [self insertIntoArrayWithName:aUsername];
                }else {
                    NSLog(@"接受失败");
                }
            });
        });
    
    }];
    
    //将事件给控制器
    [alertVC addAction:acceptAction];
    [alertVC addAction:rejectAction];
    //最后弹出提示框
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark --- 插入单条cell
- (void)insertIntoArrayWithName:(NSString *)aName {
    //1.为了防止好友列表显示重复
    if ([self.dataArray containsObject:aName]) {
        return;
        //containsObject :判断对象是否在数组中
    }
    //2.添加好友
    [self.dataArray addObject:aName];
    //3.插入cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


//代理方法：收到对方同意添加好友的回调方法
- (void)friendRequestDidApproveByUser:(NSString *)aUsername
{
    //展示信息
    [self insertIntoArrayWithName:aUsername];
}

//代理方法：收到对方拒绝添加好友的回调方法
- (void)friendRequestDidDeclineByUser:(NSString *)aUsername
{
    NSLog(@"拒绝我,你一定会后悔的");
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark --- 删除cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 先删数据 再删界面
        //1.要删除的好友名
        NSString *name = self.dataArray[indexPath.row];
        //2.删除好友
        [[ClientManager sharedClientManager] deleteContactWithUserName:name complete:^(EMError *error) {
            if (error == nil) {
                NSLog(@"删除好友成功");
                [self.dataArray removeObject:name];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else {
                NSLog(@"删除好友失败");
            }
                
        }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ChatTVC *chatTVC = segue.destinationViewController;
    //要获取当前点击的cell上显示的用户名
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *tempName = self.dataArray[indexPath.row];
    //传值
    chatTVC.friendName = tempName;
}


@end
