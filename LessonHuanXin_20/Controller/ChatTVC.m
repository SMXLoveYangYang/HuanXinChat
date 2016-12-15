//
//  ChatTVC.m
//  LessonHuanXin_20
//
//  Created by SMX on 2016/10/10.
//  Copyright © 2016年 SMX. All rights reserved.
//

#import "ChatTVC.h"

#import "EMSDK.h"


@interface ChatTVC ()<EMChatManagerDelegate>

//会话对象,用于管理消息当前登录的账号的相关信息，因为用户可以同时和多人聊天,所以我们用此对象来记录当前的聊天对象
@property (nonatomic, strong) EMConversation *conversation;

//声明数据源数组
@property (nonatomic, strong) NSMutableArray *dataArray;


@end

@implementation ChatTVC

- (NSMutableArray *)dataArray
{
    if(!_dataArray){
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
//会话对象 -- 懒加载
- (EMConversation *)conversation
{
    if (!_conversation) {
        self.conversation = [[EMClient sharedClient].chatManager getConversation:self.friendName type:EMConversationTypeChat createIfNotExist:YES];
        //参数1：聊天对象   参数2：会话类型  参数3：没有此对象时是否创建
    }
    return _conversation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.添加代理对象
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //2.查询跟聊天对象的所有信息
    //聊天信息都在本地存储
    [self.conversation loadMessagesFrom:10 to:100 count:INT_MAX completion:^(NSArray *aMessages, EMError *aError) {
        //将消息放入数据源数组
        [self.dataArray addObjectsFromArray:aMessages];
        [self.tableView reloadData];
    }];
  
}

#pragma mark --- 发送消息事件
- (IBAction)sendMessageAction:(UIBarButtonItem *)sender {
    
    //1.消息体
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"你个骚猪"];
    //2.告诉服务器消息的发送者
    NSString *from = [[EMClient sharedClient] currentUsername];
    //3.生成消息
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.friendName body:body ext:nil];
    //参数1：消息的识别 参数2：消息的发送者 参数3：消息的接收者 参数4：消息内容
    //4.设置聊天的类型
    message.chatType = EMChatTypeChat;
    //5.发送给服务器
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        if (error == nil) {
            NSLog(@"消息发送成功");
            //插入cell
            [self insertIntoArrayWithMessage:message];
        }else {
            NSLog(@"消息发送失败");
        }
            
    }];
}

//插入cell
- (void)insertIntoArrayWithMessage:(NSString *)message {
    [self.dataArray addObject:message];
    //插入cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark --- 聊天的代理方法
//收到消息
- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *tempMessage in aMessages) {
        if ([tempMessage.conversationId isEqualToString:self.conversation.conversationId]) {
            //代表此消息是当前会话的消息
            [self insertIntoArrayWithMessage:tempMessage];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    //1.获取消息
    EMMessage *message = self.dataArray[indexPath.row];
    //2.判断消息的来源
    if (message.direction == EMMessageDirectionSend) {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    //给cell赋值
    EMMessageBody *messageBody = message.body;
    //转为文字消息
    EMTextMessageBody *textBody = (EMTextMessageBody *)messageBody;
    NSString *text = textBody.text;
    cell.textLabel.text = text;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
