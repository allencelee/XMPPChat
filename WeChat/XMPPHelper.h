//
//  XMPPHelper.h
//  WeChat
//
//  Created by imac on 15/11/17.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

typedef void(^loginSuccessBlock)(void);
typedef void(^loginFailBlock)(NSString *info);
typedef void(^fenchFridendList)(id result);
typedef void(^logoutSuccessBlock)(void);
typedef void(^registerSuccessBlock)(void);
typedef enum {
    kTypeLogin,
    kTypeRegister
}ConnectType;
#import <Foundation/Foundation.h>
#define kXMPPHosetName @"lyl"
#define kXMPPHostAddress @"127.0.0.1"
#define kHostPort 5222

@interface XMPPHelper : NSObject
{

    ConnectType _connectType;

}
@property(nonatomic,strong)XMPPStream *stream;
@property(nonatomic,strong)XMPPRoster *roster;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *password;

@property(nonatomic,copy)loginSuccessBlock loginSuccessBlock;
@property(nonatomic,copy)loginFailBlock loginFailBlock;
@property(nonatomic,copy)fenchFridendList fenchFriendList;
@property(nonatomic,copy)logoutSuccessBlock logoutSuccessBlock;
@property(nonatomic,copy)registerSuccessBlock registerSuccessblock;

+(instancetype)shareInstance;
//登陆
-(void)login:(NSString *)username password:(NSString *)password loginSuccessBlock:(loginSuccessBlock)block loginFailBlock:(loginFailBlock)failBlcok;
//获取好友列表
-(void)loadFriendList:(fenchFridendList)fenchfriendList;
//发送消息
-(void)sendMessage:(NSString *)message toUser:(NSString *)jid;
//注销
-(void)logoutAction:(logoutSuccessBlock)block;
//注册
-(void)registerAction:(NSString *)username password:(NSString *)password registerSuccessBlock:(registerSuccessBlock)registerBlock;

@end
