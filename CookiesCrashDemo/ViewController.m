//
//  ViewController.m
//  CookiesCrashDemo
//
//  Created by Pierre de La Morinerie on 27/02/13.
//  Copyright (c) 2013 Pierre de La Morinerie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSTimer  *_killCountdownTimer;
    NSInteger _countdown;
}
@property IBOutlet UILabel *countdownLabel;
@end

@implementation ViewController

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkForMissingCookie];
    [self setCookieAndStartKillCountdown];
}

- (void) checkForMissingCookie
{
    BOOL shouldHaveSavedCookies = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldHaveSavedCookies"];
    BOOL hasSavedCookies = [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] count] > 0;
    
    if (!shouldHaveSavedCookies)
        return;
    
    NSString *title, *message;
    if (shouldHaveSavedCookies && ! hasSavedCookies) {
        title = @"Cookie data has been lost!";
        message = @"The saved cookie is gone - because the app was killed before the cookie storage was persisted to the disk.";
        
    } else {
        title = @"Hum - cookie data is still there.";
        message = @"The cookie storage is persisted when the app goes to the background or terminates gracefully. "
        "Did you let the app be killed without putting it in the background?";
    }
    
    
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShouldHaveSavedCookies"];
}

- (void) setCookieAndStartKillCountdown
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    // Clear the cookie storage for demonstration purposes
    for (id cookie in [cookieStorage cookies])
        [cookieStorage deleteCookie:cookie];
    
    // Add a cookie to the cookie storage
    [cookieStorage setCookie:
     [NSHTTPCookie cookieWithProperties:
      [NSDictionary dictionaryWithObjectsAndKeys:
       @"Name", NSHTTPCookieName,
       @"Value", NSHTTPCookieValue,
       @"http://example.com", NSHTTPCookieOriginURL,
       @"/", NSHTTPCookiePath,
       @"2014-10-26 00:00:00 -0700", NSHTTPCookieExpires,
       nil]]];
    NSAssert([[cookieStorage cookies] count] > 0, @"There should be a cookie in the storage at this point");
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShouldHaveSavedCookies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Start a countdown that kills our process when reaching zero
    _countdown = 6;
    _killCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(countdownTick)
                                                         userInfo:nil
                                                          repeats:YES];
    [self countdownTick];
}

- (void) countdownTick
{
    _countdown -= 1;
    
    _countdownLabel.text = [NSString stringWithFormat:
                            @"The app will be killed in %i s.",
                            _countdown];
    
    if (_countdown == 0)
        [self killProcess];
}

- (void) killProcess
{
    pid_t pid = getpid();
    kill(pid, SIGKILL);
}

@end
