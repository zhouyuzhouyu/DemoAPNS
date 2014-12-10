//
//  ApnsManager.h
//  hbgj
//
//  Created by 张 林 on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kDefault_Apn_Token @"1111"
@class UIApnsAlertView;

@interface ApnsManager : NSObject <UIAlertViewDelegate> {
    NSString *_token;
    UIApnsAlertView *avApns;
    NSDate *dateRefresh;
}

@property (nonatomic,retain) NSString *token;
@property (nonatomic,retain) UIApnsAlertView *avApns;
@property (nonatomic,retain) NSDate *dateRefresh;

+ (id)shared;

- (void)refresh; //刷新apns
- (void)registerForRemoteNotification;

//处理启动是由APNS启动
- (BOOL)handleLaunchOptionsRemoteNotification:(NSDictionary *)launchOptions;

//处理收到APNS消息
- (void)handleReceiveRemoteNotification:(NSDictionary *)userInfo;

//处理收到注册成功的消息
- (void)handleRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;

//处理收到注册失败的消息
- (void)handleFailToRegisterForRemoteNotificationsWithError:(NSError *)err;


@end









//-------------------------------------------------------------------------------------------------------------
//
// UIApnsAlertView
// Apns消息弹框
//--------------------------------------------------------------------------------------------------------------
@interface UIApnsAlertView : UIAlertView {
	NSDictionary *dicApns;
	int nType; //1:航班订阅 (确定)  2:航班订阅(关闭,显示) 3：酒店订阅（确定） 4：酒店订阅（确定，显示）
}
@property (nonatomic, retain) NSDictionary *dicApns;
@property (nonatomic, assign) int nType;

@end

