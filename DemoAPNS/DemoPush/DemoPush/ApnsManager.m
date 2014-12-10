//
//  ApnsManager.m
//  hbgj
//
//  Created by 张 林 on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ApnsManager.h"


#define kUserDefaults_Key_APNSToken @"kUserDefaults_Key_APNSToken"

static ApnsManager *sharedApnsManager = nil;

@implementation ApnsManager
@synthesize token = _token;
@synthesize avApns;
@synthesize dateRefresh;

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
        if (_token.length==0 ) {
            self.token = kDefault_Apn_Token;
        }
        [self refresh];
    }
    return self;
}

- (void)refresh {
    if(dateRefresh!=nil) {
        NSTimeInterval tval = [dateRefresh timeIntervalSinceNow];
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
#if 1
    const char *devTokenBytes = [devToken bytes];
	int len = [devToken length];
	char temps[1024];
	temps[0] = '\0';
	for ( int i=0; i<len; i++ ) {        
		char temps2[100];
		sprintf(temps2, "%02x", (unsigned char) devTokenBytes[i] );
		strcat( temps, temps2 );
	}

	NSString *strToken = [NSString stringWithCString:temps encoding:NSASCIIStringEncoding];
	NSLog(@"token = %@",strToken);
#endif
//    NSString *strToken = [NSString stringWithFormat:@"%@",devToken];
//    NSLog(@"deviceToken:%@", strToken);
//    strToken = [strToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]; //去掉"<>"
//    strToken = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉中间空格
//    NSLog(@"deviceToken:%@", strToken);
	
	//新旧token不一样才上传
	if( ![strToken isEqualToString:self.token] )
	{
//        [[AppSetting shared] settingSetString:strToken forKey:@"apntoken"];
        [[NSUserDefaults standardUserDefaults] setObject:strToken forKey:kUserDefaults_Key_APNSToken];
        self.token = strToken;
#if 0
		//上传设备信息
        NSString *stampId = [theApp stampId];
        if (ZYIsNullOrEmpty(stampId)) {
            ZYSocketRequest *request = [ZYSocketRequest getMachineStampID];
            [ZYSocket socketRequset:request success:^(ZYSocketResponse *socketResponse) {
                NSDictionary *dic = [socketResponse.arrRowData objectAtIndex:0];
                NSString *stampId = [dic objectForKey:@"v_stamp_id"];
                [theApp saveStampId:stampId];
                
                ZYSocketRequest *request = [ZYSocketRequest bindTokenRequest:strToken stamp:[theApp stampId]];
                [ZYSocket socketRequset:request success:^(ZYSocketResponse *socketResponse) {
                    CJLog(@"%s\n 绑定token和stampId 成功11",__FUNCTION__);
                } failure:^(ZYSocketResponse *socketResponse) {
                    CJLog(@"%s\n 上传token到服务器失败11",__FUNCTION__);
                }];
            } failure:^(ZYSocketResponse *socketResponse) {
                
            }];
        }
        else
        {
            ZYSocketRequest *request = [ZYSocketRequest bindTokenRequest:strToken stamp:[theApp stampId]];
            [ZYSocket socketRequset:request success:^(ZYSocketResponse *socketResponse) {
                CJLog(@"%s\n 上传token和stampId 成功12",__FUNCTION__);
            } failure:^(ZYSocketResponse *socketResponse) {
                CJLog(@"%s\n 上传token和stampId 到服务器失败12",__FUNCTION__);
            }];
        }
    #endif
	}

}

//处理收到注册失败的消息
- (void)handleFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@">>>FailToRegisterForRemoteNotifications: %@", err);
//    [[NSNotificationCenter defaultCenter] postNotificationName:k_system_taken_register_failure object:nil];
}

- (BOOL)handleLaunchOptionsRemoteNotification:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary *dicApns = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    dicGetDic(launchOptions, UIApplicationLaunchOptionsRemoteNotificationKey);
    if ( dicApns ) {
#if 1
        NSString *strMessage = [[dicApns objectForKey:@"aps"] objectForKey:@"alert"];
//        dicGetString( dicGetDic(dicApns, @"aps"), @"alert" );

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"启动时收到APNS通知" message:strMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
//        [av release];
#endif

        return YES;
	}
    
    return NO;
}

- (void)handleReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"notification body = %@", userInfo);
	
	if ( avApns!=nil ) {
		//[avApns dismissWithClickedButtonIndex:-1 animated:YES];
		self.avApns = nil;
	}
	
	NSDictionary *dicApns = userInfo;
	NSString *strMessage = [[dicApns objectForKey:@"aps"] objectForKey:@"alert"];
//    dicGetString( dicGetDic(dicApns, @"aps"), @"alert" );
	
    NSLog(@"receive:%@", strMessage);
    UIApplication *application = [UIApplication sharedApplication];
    NSLog(@"applicationState:%ld", application.applicationState);
    
    if ( application.applicationState == UIApplicationStateActive ) {
#if 1
        //激活状态下收到通知
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"收到APNS通知" message:strMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
//        [av release];
#endif
    }
    else {
		//非激活状态下收到通知
    }
}

- (void)dealloc {
    self.token = nil;
    self.avApns = nil;
    self.dateRefresh = nil;

//    [super dealloc];
}

@end



@implementation UIApnsAlertView
@synthesize dicApns;
@synthesize nType;

- (void)dealloc {
//	[dicApns release];
//    [super dealloc];
}


@end
