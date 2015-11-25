//
//  ViewController.m
//  WeChat
//
//  Created by byy on 15/10/7.
//  Copyright (c) 2015年 byy. All rights reserved.
//

#import "ViewController.h"
#import "XMPPHelper.h"
@interface ViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (nonatomic,strong) UIAlertView *alertView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;


@end

@implementation ViewController

/*
 集成XMPPFramework：
    1、从解压的XMPPFramework里面copy 6个文件夹、从XMPPFramework/Xcode/iPhoneXMPP里面copyXMPPFramework.h文件 形成XMPP文件夹，把XMPP文件夹添加到工程
    2、添加依赖库：libresolv.dylib、libxml2.dylib
    3、Header Search Paths：$(SDKROOT)/usr/include/libxml2
 */

/*
 1、如果openfire安装后无法启动，需要安装java的jdk
 2、Mac上彻底删除openfire：
    sudo rm -rf /Library/PreferencePanes/Openfire.prefPane
    sudo rm -rf /usr/local/openfire
    sudo rm -rf /Library/LaunchDaemons/org.jivesoftware.openfire.plist
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginButton.layer.cornerRadius = 10;
    _loginButton.layer.masksToBounds = YES;
    _registerButton.layer.cornerRadius = 10;
    _registerButton.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (IBAction)loginAction:(id)sender {
    NSString *user = self.usernameTF.text;
    NSString *pass = self.pwdTF.text;
    
    if (user.length == 0 || pass.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户名密码不能为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    XMPPHelper *helper = [XMPPHelper shareInstance];
    
    [helper login:user password:pass loginSuccessBlock:^{
        //登录成功的跳转
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"kUserListViewCtrl"];
        
        [UIView transitionWithView:self.view.window
                          duration:.4
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.view.window.rootViewController = nav;
                        }
                        completion:NULL];
        
    } loginFailBlock:^(NSString *info){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:info delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定" ,nil];
        [alert show];
        
    }];
}

- (IBAction)registerAction:(id)sender {
    NSString *user = self.usernameTF.text;
    NSString *pass = self.pwdTF.text;
    
    if (user.length == 0 || pass.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户名密码不能为空" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    
    
    XMPPHelper *helper = [XMPPHelper shareInstance];
    
    [helper registerAction:user password:pass registerSuccessBlock:^{
        
        
        _alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"注册成功，是否用该账号登陆" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登陆", nil];
        [_alertView show];
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex==1) {
       
        //注册成功的跳转
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"kUserListViewCtrl"];
        
        [UIView transitionWithView:self.view.window
                          duration:.4
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.view.window.rootViewController = nav;
                        }
                        completion:NULL];
    }
}

@end
