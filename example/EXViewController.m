#import "EXViewController.h"
#import "BCTextView.h"

@implementation EXViewController

- (void)viewDidLoad {
	BCTextView *textView = [[[BCTextView alloc] initWithHTML:
							 @"Lorem <b>ipsum</b> dolor sit amet, consectetur adipiscing elit. "
							 @"Quisque rhoncus <i>tincidunt <b>est, id pharetra felis</b></i> dignissim non. "
							 @"Phasellus aliquet scelerisque sodales. Mauris a libero vel "
							 @"ipsum congue congue at sit amet augue. "
							 @"1234567890123456789012345678901234567890123456789012345678901234567890 "
							 @"the previous line was to test character wrapping"] 
							autorelease];
	textView.frame = self.view.bounds;
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textView.backgroundColor = [UIColor whiteColor];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
