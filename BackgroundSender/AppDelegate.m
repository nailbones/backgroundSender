#import "AppDelegate.h"

static NSString * const kAPIScheme   = @"https";
static NSString * const kAPIHostName = @"jsonplaceholder.typicode.com";
static NSString * const kAPIRootPath = @"/posts";
static NSString * const kURL         = @"/1";

static NSString * const kNotificationCategory = @"LOCAL_NOTIFICATION_CATEGORY";
static NSString * const kNotificationIdentifier = @"LOCAL_NOTIFICATION_IDENTIFIER";

@interface AppDelegate ()<NSURLSessionDelegate, NSURLSessionDataDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,NSURLSessionTaskDelegate>

@end

@implementation AppDelegate

- (instancetype)sharedDelegate
{
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self registerNotificationTypes];

    [self handleNotificationFromLaunchOptions:launchOptions];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
}

#pragma mark - notification handling

- (void)registerNotificationTypes {
    // Register the supported interaction types of notification
    UIUserNotificationType types                     = (UIUserNotificationType) (UIUserNotificationTypeBadge |
                                                                                 UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void)handleNotificationFromLaunchOptions:(NSDictionary *)launchOptions
{
    NSLog(@"handleNotificationFromLaunchOptions");
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification * localNotification =[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSDictionary * userInfo = localNotification.userInfo;
        NSLog(@"Notification: %@", userInfo);
    }
}

- (void)application:(UIApplication *) application handleActionWithIdentifier: (NSString *) identifier forLocalNotification: (UILocalNotification *) notification completionHandler: (void (^)()) completionHandler {

    if ([notification.category isEqualToString: kNotificationCategory]) {

        if ([identifier isEqualToString: kNotificationIdentifier]) {
            NSLog(@"Did handle action with identifier");
            [self sendHTTPRequest];
        }
    }

    completionHandler();
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification %@", notification.userInfo);
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler
{
    NSLog(@"handleEventsForBackgroundURLSession");
}

#pragma mark - network handling

- (void)sendRequestTo:(NSString *)url
           withMethod:(NSString *)method
             withBody:(NSDictionary *)body
          andCallback:
(void (^)(NSHTTPURLResponse *response, NSData *data))callback {
    NSLog(@"FOREGROUND REQUEST");
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];

    /* Create session, and optionally set a NSURLSessionDelegate. */
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:nil
                                                     delegateQueue:nil];

    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme           = kAPIScheme;
    urlComponents.host             = kAPIHostName;
    urlComponents.path             = [NSString stringWithFormat:@"%@%@", kAPIRootPath, url];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL]];
    request.HTTPMethod           = method;

    // Headers
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (body != nil && ![method isEqualToString:@"GET"]) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body
                                                           options:kNilOptions
                                                             error:NULL];

    NSLog(@"Request Body: %@", body );

    }

    NSLog(@"Making request: %@", request);

    /* Start a new Task */
    NSURLSessionDataTask *task = [session
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *data, NSURLResponse *response,
                                                      NSError *error) {
                                      if (error == nil) {
                                          // Success
                                          NSLog(@"URL Session Task Succeeded: HTTP %ld",
                                                ((NSHTTPURLResponse *)response).statusCode);
                                          callback((NSHTTPURLResponse *)response, data);
                                          NSLog(@"😀 url: %@ :: %@", url, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

                                      } else {
                                          // Failure
                                          callback((NSHTTPURLResponse *)response,data);
                                          NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
                                      }
                                  }];
    [task resume];
}

- (void)sendHTTPRequest
{
    NSString * url = [[NSString alloc] initWithFormat:kURL];

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];

    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive){

        NSLog(@"🗻sendBackgroundRequestTo");

        [self
         sendBackgroundRequestTo:url
         withMethod:@"PUT"
         withBody:nil
         identifier:[NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSinceReferenceDate]
         andCallback:^(NSHTTPURLResponse *response, NSData *data) {
             NSLog(@"💡CALLBACK!");
         }];

    }else{
        NSLog(@"sendRequestTo");
        [self
         sendRequestTo:url
         withMethod:@"PUT"
         withBody:nil
         andCallback:^(NSHTTPURLResponse *response, NSData *data) {
             NSLog(@"foreground callback");
         }];
    }

    
}


- (void)sendBackgroundRequestTo:(NSString *)url
                     withMethod:(NSString *)method
                       withBody:(NSDictionary *)body
                     identifier:(NSString *)identifier
                    andCallback:
(void (^)(NSHTTPURLResponse *response, NSData *data))callback {

    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    sessionConfig.sessionSendsLaunchEvents = true;
    sessionConfig.discretionary = false;
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    sessionConfig.timeoutIntervalForResource = 60 * 60 * 24; //One day. Default is 7 days!
                                                             //    sessionConfig.networkServiceType = NSURLNetworkServiceTypeBackground;

    /* Create session, and optionally set a NSURLSessionDelegate. */
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme           = kAPIScheme;
    urlComponents.host             = kAPIHostName;
    urlComponents.path             = [NSString stringWithFormat:@"%@%@", kAPIRootPath, url];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[urlComponents URL]];
    request.HTTPMethod           = method;

    // Headers
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (body != nil && ![method isEqualToString:@"GET"]) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body
                                                           options:kNilOptions
                                                             error:NULL];

        NSLog(@"Request Body: %@", body );
    }

    NSLog(@"Making request: %@", request);

    /* Start a new Task */
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"didBecomeInvalidWithError %@",error);
}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"willSendRequestForAuthenticationChallenge");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSLog(@"didReceiveChallenge");

}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{

    NSLog(@"🌋URLSession datatask didReceiveResponse");

    if (((NSHTTPURLResponse *)response).statusCode == 200) {

        [self createLocalNotification:@"URLSession datatask didReceiveResponse" scheduleTime:[NSDate date] userInfo:@{@"key":@"value"}];
    }else{
        NSLog(@"RESPONSE not 200 %ld", ((NSHTTPURLResponse *)response).statusCode);
    }

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    NSLog(@"URLSession dataTask didReceiveData");
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL{
    NSLog(@"connectionDidFinishDownloading........ %@",connection);
    
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
}

#pragma mark - notification creation

-(void)activityNotificationSetup {

    UIMutableUserNotificationAction *otherAction = [[UIMutableUserNotificationAction alloc] init];
    otherAction.activationMode = UIUserNotificationActivationModeBackground;
    otherAction.destructive = NO;
    otherAction.authenticationRequired = NO;

    otherAction.identifier = kNotificationIdentifier;
    otherAction.title = @"Send HTTP Request";

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = kNotificationCategory;

    // Set the actions to display in the default context
    [notificationCategory setActions:@[otherAction] forContext:UIUserNotificationActionContextDefault];
    // Set the actions to display in a minimal context
    [notificationCategory setActions:@[otherAction] forContext:UIUserNotificationActionContextMinimal];


    NSSet *categories = [NSSet setWithObjects:notificationCategory, nil];
    UIUserNotificationSettings * userSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (userSettings.types == UIUserNotificationTypeNone) {
        UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge |
                                                                 UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        userSettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];

    }else{
        userSettings = [UIUserNotificationSettings settingsForTypes:userSettings.types categories:categories];
    }

    [[UIApplication sharedApplication] registerUserNotificationSettings:userSettings];
}


-(void)createLocalNotification:(NSString*)message scheduleTime:(NSDate *)scheduleTime userInfo:(NSDictionary *)userInfo{

    NSLog(@"createLocalNotification");
    [self activityNotificationSetup];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];

    localNotification.category = kNotificationCategory;

    localNotification.fireDate = scheduleTime;
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - STUFF
- (void)sendThing
{
    NSLog(@"sendThing");
    [self sendHTTPRequest];
}

- (void)scheduleThing
{
    NSLog(@"scheduleThing");
    [self createLocalNotification:@"Test"
                     scheduleTime:[NSDate dateWithTimeIntervalSinceNow:5]
                         userInfo:@{@"key":@"value"}];
}

@end
