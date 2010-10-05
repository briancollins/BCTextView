#import "EXAppDelegate.h"
#import "EXViewController.h"

@implementation EXAppDelegate

@synthesize window, exampleView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window makeKeyAndVisible];
	
	self.exampleView = [[[EXViewController alloc] init] autorelease];
	[self.window addSubview:self.exampleView.view];
	
    return YES;
}

@end
