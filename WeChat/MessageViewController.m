//
//  MessageViewController.m
//  WeChat
//
//  Created by byy on 15/10/8.
//  Copyright (c) 2015年 byy. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "XMPPHelper.h"
#define kInputViewHeight    50

@interface MessageViewController ()<UITextFieldDelegate>
{
    __weak IBOutlet NSLayoutConstraint *inputViewBottomLayout;
    __weak IBOutlet NSLayoutConstraint *tbViewBottomLayout;
    
    __weak IBOutlet UITextField *textField;
    __weak IBOutlet UITableView *tbView;
}

@property(nonatomic, strong)NSMutableArray *data;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = self.toUser.jid;
    self.navigationController.navigationBar.translucent = NO;
    
    //监听键盘弹出的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveMessage:) name:@"ll" object:nil];
    
    //加载数据
    [self loadData];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //每次进来的时候 滑动到 tbView 最后一条消息
    NSIndexPath *indePath = [NSIndexPath indexPathForRow:self.data.count-1 inSection:0];
    [tbView scrollToRowAtIndexPath:indePath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __FUNCTION__);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//加载数据
- (void)loadData {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"messages" ofType:@"plist"];
    NSArray *msgArray = [NSArray arrayWithContentsOfFile:path];
    
    self.data = [NSMutableArray arrayWithCapacity:msgArray.count];
    for (NSDictionary *dic in msgArray) {
        
        Message *msg = [[Message alloc] init];
        msg.content = dic[@"content"];
        msg.isSelf = [dic[@"self"] boolValue];
        msg.icon = dic[@"icon"];
        msg.time = dic[@"time"];
        
        [self.data addObject:msg];
    }
}

//收到了好友消息
- (void)receiveMsg:(NSNotification *)notification {
    
    NSDictionary *msg = notification.userInfo;
    
    NSString *text = msg[@"text"];
    
    [self addMessage:text isSelf:NO];
}

//往tableview里面插入消息
- (void)addMessage:(NSString *)text isSelf:(BOOL)isSelf {
    
    //创建消息对象
    Message *msg = [[Message alloc] init];
    msg.content = text;
    msg.icon = isSelf?@"icon01.jpg":@"icon02.jpg";
    msg.isSelf = isSelf;
    
    //更新数据源
    [self.data addObject:msg];
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_data.count-1 inSection:0];
    
    //往tbView最后插入一个单元格
    [tbView insertRowsAtIndexPaths:@[lastIndexPath]
                  withRowAnimation:(isSelf ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft)];
    
    //动画显示最后的消息
    [tbView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *msg = self.data[indexPath.row];
    CGFloat height = msg.frame.size.height;
    return height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"kMsgCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    cell.msg = self.data[indexPath.row];
    
    return cell;
}


#pragma mark - 键盘事件

//单击窗口回收键盘
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self keyboardWillHide:nil];
}

//滑动窗口回收键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self keyboardWillHide:nil];
}


//加动画
-(void)animationShowOrHideInputView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillChange:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    //改变约束的值
    inputViewBottomLayout.constant = keyFrame.size.height;
    tbViewBottomLayout.constant = keyFrame.size.height + kInputViewHeight;
    
    //加动画
    [self animationShowOrHideInputView];
    
    //滑动到 tbView 最后一条消息
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.data.count-1 inSection:0];
    [tbView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    //回收键盘
    [self.view endEditing:YES];
    
    inputViewBottomLayout.constant = 0;
    tbViewBottomLayout.constant = kInputViewHeight;
    
    [self animationShowOrHideInputView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tField{

    NSString *message = tField.text;
    
    XMPPHelper *helper = [XMPPHelper shareInstance];
    
    [helper sendMessage:message toUser:self.toUser.jid];
    
    [self addMessage:message isSelf:YES];
    
    return YES;
}

-(void)reciveMessage:(NSNotification *)notifi{

    NSString *message = notifi.object;
    
    [self addMessage:message isSelf:NO];
}


@end
