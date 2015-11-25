//
//  MessageViewController.h
//  WeChat
//
//  Created by byy on 15/10/8.
//  Copyright (c) 2015年 byy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MessageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)User *toUser;

@end
