//
//  ApnsManager.h
//
//
//  Created by zoyu on 14-12-10.
//  Copyright (c) 2012年 hcdl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kDefault_Apn_Token @"1111"

@interface ApnsManager : NSObject

@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSDate *dateRefresh;

+ (id)shared;

- (void)refresh; //刷新apns

//处理启动是由APNS启动
- (BOOL)handleLaunchOptionsRemoteNotification:(NSDictionary *)launchOptions;

//处理收到APNS消息
- (void)handleReceiveRemoteNotification:(NSDictionary *)userInfo;

//处理收到注册成功的消息
- (void)handleRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;

//处理收到注册失败的消息
- (void)handleFailToRegisterForRemoteNotificationsWithError:(NSError *)err;


@end








