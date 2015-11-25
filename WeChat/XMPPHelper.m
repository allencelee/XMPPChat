//
//  XMPPHelper.m
//  WeChat
//
//  Created by imac on 15/11/17.
//  Copyright (c) 2015年 JayWon. All rights reserved.
//

#import "XMPPHelper.h"
#import "User.h"


static XMPPHelper *xmppHelper = nil;
@interface XMPPHelper()<XMPPStreamDelegate>

@end
@implementation XMPPHelper

//1.创建stream对象建立连接
// stream对象负责客户端与服务器的链接，传输xml流信息

+(instancetype)shareInstance{
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        xmppHelper = [[XMPPHelper alloc]init];
        
        [xmppHelper setupStream];
    });
    
    return xmppHelper;
    
};

-(void)setupStream{
    //stream对象
    _stream = [[XMPPStream alloc]init];
    //设置重新链接对象
    XMPPReconnect *reconnect = [[XMPPReconnect alloc]init];
    //设置花名册
    XMPPRosterCoreDataStorage *storage = [[XMPPRosterCoreDataStorage alloc]init];
    self.roster = [[XMPPRoster alloc]initWithRosterStorage:storage];
    
    [reconnect activate:self.stream];
    [self.roster activate:self.stream];
    //设置代理
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //设置端口和地址
    [self.stream setHostName:kXMPPHostAddress];
    [self.stream setHostPort:kHostPort];
    
}

#pragma mark XMPP 对外公开方法

-(void)login:(NSString *)username password:(NSString *)password loginSuccessBlock:(loginSuccessBlock)block loginFailBlock:(loginFailBlock)failBlcok{

    _connectType = kTypeLogin;
    
    self.username = username;
    self.password = password;
    
    self.loginFailBlock = failBlcok;
    self.loginSuccessBlock = block;
    
    if (![self connect]) {
        
        if (self.loginFailBlock) {
            
            self.loginFailBlock(@"网络错误");
        }
    }
    
}
/**
 <iq from='guojing@wxhl' type='get' id='roster_1' to='域名'>
 <query xmlns='jabber:iq:roster'/> <!-- iq 信息有多种，根据命名空间来区分-->
 </iq>
 
 */

-(void)loadFriendList:(fenchFridendList)fenchfriendList{

    self.fenchFriendList = fenchfriendList;
    
    NSXMLElement *iqElement = [[NSXMLElement alloc]initWithName:@"iq"];
    XMPPJID *jid = self.stream.myJID;

    [iqElement addAttributeWithName:@"from" stringValue:jid.description];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"id" stringValue:@"123"];
    [iqElement addAttributeWithName:@"to" stringValue:kXMPPHosetName];
    NSXMLElement *queryElement = [[NSXMLElement alloc]initWithName:@"query" xmlns:@"jabber:iq:roster"];
    [iqElement addChild:queryElement];
    [self.stream sendElement:iqElement];
}

//发送消息的格式
/**
 <message
 to='huangrong@wxhl'
 from='guojing@wxhl'
 type='chat'
 xml:lang='en'>
 <body>有个bug帮我看下</body>
 </message>
 */

-(void)sendMessage:(NSString *)message toUser:(NSString *)jid{

    NSXMLElement *element = [NSXMLElement elementWithName:@"message"];
    [element addAttributeWithName:@"to" stringValue:jid];
    XMPPJID *myJid = self.stream.myJID;
    [element addAttributeWithName:@"from" stringValue:myJid.description];
    [element addAttributeWithName:@"type" stringValue:@"chat"];

    NSXMLElement *bodyElement = [NSXMLElement elementWithName:@"body" stringValue:message];
    [element addAttributeWithName:@"xml:lang" stringValue:@"en"];
    
    [element addChild:bodyElement];
    [self.stream sendElement:element];
}

-(void)logoutAction:(logoutSuccessBlock)block{
   
    [self.stream disconnect];
    [self outline];
    
    if (block) {
        block();
    }
}

-(BOOL)connect{

    if ([self.stream isConnected]) {
        
        [self.stream disconnect];
    }
    
    NSString *jidString = [NSString stringWithFormat:@"%@@%@",self.username,kXMPPHosetName];
    
    XMPPJID *jid = [XMPPJID jidWithString:jidString];
    [self.stream setMyJID:jid];
    
    return [self.stream connectWithTimeout:10 error:nil];
}

-(void)online{
    
    XMPPPresence *presence = [XMPPPresence presence];
    [self.stream sendElement:presence];
}
-(void)outline{
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.stream sendElement:presence];
}

-(void)registerAction:(NSString *)username password:(NSString *)password registerSuccessBlock:(registerSuccessBlock)registerBlock{

    _connectType = kTypeRegister;
    self.username = username;
    self.password = password;
    
    self.registerSuccessblock = registerBlock;
    
    [self connect];
    
    }


#pragma mark XMPP 代理方法
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接成功");
    if (_connectType == kTypeRegister) {
        
        [self.stream registerWithPassword:self.password error:nil];
    }else if (_connectType == kTypeLogin){
    
        [self.stream authenticateWithPassword:self.password error:nil];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{

    NSLog(@"验证成功");
    [self online];
    if (self.loginSuccessBlock) {
        self.loginSuccessBlock();
    }
}



- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{

    NSLog(@"验证失败");
    if (self.loginFailBlock) {
        self.loginFailBlock(@"密码错误");
    }
    
}
/*
 <iq xmlns="jabber:client" type="result" to="allence@lyl/fbee6473">
   <query xmlns="jabber:iq:roster">
     <item jid="wangnima@127.0.0.1" name="" ask="subscribe" subscription="none">
        <group>联系人列表</group>
     </item>
     <item jid="wangnima@lyl" name="wangnima" subscription="both">
       <group>联系人列表</group>
       <group>好友</group>
     </item>
   </query>
 </iq>

 */


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSLog(@"%@",iq);
    User *model = nil;
    NSXMLElement *querty = iq.childElement;
    
    for (NSXMLElement *itemElement in querty.children) {
       
        model = [[User alloc]init];
        model.username = [itemElement attributeStringValueForName:@"name"];
        model.jid = [itemElement attributeStringValueForName:@"jid"];
        
        for (NSXMLElement *childElement in itemElement.children) {
            
            NSString *groupName = childElement.stringValue;
            NSMutableArray *users = results[groupName];
            if (users==nil) {
                
                users = [NSMutableArray array];
                results[groupName] = users;
//                [results setValue:users forKey:groupName];
            }
            [users addObject:model];
            
        }
        
    }
    if (self.fenchFriendList) {
        self.fenchFriendList(results);
    }
    return YES;
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{

    NSString *messageString = [message body];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ll" object:messageString];
    
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    _connectType = kTypeLogin;
    self.loginSuccessBlock = self.registerSuccessblock;
    self.registerSuccessblock = nil;
    [self xmppStreamDidConnect:sender];
    
}
@end
