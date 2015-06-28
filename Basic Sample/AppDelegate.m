
#import "AppDelegate.h"
#import <Gimbal/Gimbal.h>

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // To get started with an API key, go to https://manager.gimbal.com/
#warning Instert your Gimbal Application API key below in order to see this sample application work
    [Gimbal setAPIKey:@"4b2e680c-64e1-43b8-bc98-6602a9c31cd5" options:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasBeenPresentedWithOptInScreen"] == NO)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Opt-In" bundle:nil] instantiateInitialViewController];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        [self processRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey])
    {
        [self processLocalNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]];
    }
    
    [self registerForNotifications:application];
    
    return YES;
}

# pragma mark - Remote Notification Support

- (void)registerForNotifications:(UIApplication *)application
{
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Gimbal setPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Registration for remote notifications failed with error %@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self processRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self processLocalNotification:notification];
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    GMBLCommunication *communication = [GMBLCommunicationManager communicationForRemoteNotification:userInfo];
    
    if (communication)
    {
        [self storeCommunication:communication];
    }
}

- (void)processLocalNotification:(UILocalNotification *)notification
{
    GMBLCommunication *communication = [GMBLCommunicationManager communicationForLocalNotification:notification];
    
    if (communication)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        [self storeCommunication:communication];
    }
}

- (void)storeCommunication:(GMBLCommunication *)communication
{
    UINavigationController *nv = (UINavigationController *)self.window.rootViewController;
    if ([nv.topViewController isKindOfClass:[ViewController class]])
    {
        ViewController *vc = (ViewController *)nv.topViewController;
        [vc addCommunication:communication];
    }
}

@end
