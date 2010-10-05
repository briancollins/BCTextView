@class EXViewController;

@interface EXAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	EXViewController *exampleView;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) EXViewController *exampleView;

@end

