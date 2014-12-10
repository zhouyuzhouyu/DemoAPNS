//
//  ApnsManager.m
//  
//
//  Created by zoyu on 14-12-10.
//  Copyright (c) 2014年 hcdl. All rights reserved.
//

#import "ApnsManager.h"


#define kUserDefaults_Key_APNSToken @"kUserDefaults_Key_APNSToken"

static ApnsManager *sharedApnsManager = nil;

@implementation ApnsManager

+ (id)shared {
	@synchronized(self)
	{
		if (sharedApnsManager == nil)
		{
			sharedApnsManager = [[self alloc] init];
		}
	}
	
	return sharedApnsManager;
}


- (id)init {
    self = [super init];
    if (self !=nil ) {
        self.token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaults_Key_APNSToken];
        NSLog(@"token = %@", _token);
        if (_token.length == 0 ) {
            self.token = kDefault_Apn_Token;
        }
        [self refresh];
    }
    return self;
}

- (void)refresh {
    if(self.dateRefresh!=nil) {
        NSTimeInterval tval = [self.dateRefresh timeIntervalSinceNow];
        if ( tval > -600.0 ) {
            return ;
        }
    }
    [self registerForRemoteNotification];
}

- (void)registerForRemoteNotification {
    //不管有没有token，每次都注册
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];

    self.dateRefresh = [NSDate date];
}


//处理收到注册成功的消息
- (void)handleRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {

    NSString *strToken = [NSString stringWithFormat:@"%@",devToken];
    strToken = [strToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]; //去掉"<>"
    strToken = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉中间空格
	NSLog(@"deviceToken:%@", strToken);
	//新旧token不一样才上传
	if( ![strToken isEqualToString:self.token] )
	{
        [[NSUserDefaults standardUserDefaults] setObject:strToken forKey:kUserDefaults_Key_APNSToken];
        self.token = strToken;
	}
}

//处理收到注册失败的消息
- (void)handleFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@">>>FailToRegisterForRemoteNotifications: %@", err);
}

- (BOOL)handleLaunchOptionsRemoteNotification:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary *dicApns = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ( dicApns ) {
#if 1
        NSString *strMessage = [[dicApns objectForKey:@"aps"] objectForKey:@"alert"];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"启动时收到APNS通知" message:strMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
#endif

        return YES;
	}
    
    return NO;
}

- (void)handleReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"notification body = %@", userInfo);
	
	NSDictionary *dicApns = userInfo;
	NSString *strMessage = [[dicApns objectForKey:@"aps"] objectForKey:@"alert"];
//    dicGetString( dicGetDic(dicApns, @"aps"), @"alert" );
	
    NSLog(@"receive:%@", strMessage);
    UIApplication *application = [UIApplication sharedApplication];
    if ( application.applicationState == UIApplicationStateActive ) {
#if 1
        //激活状态下收到通知
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"收到APNS通知" message:strMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
#endif
    }
    else {
		//非激活状态下收到通知
    }
}


@end


