#import "EXViewController.h"
#import "BCTextView.h"

@implementation EXViewController

- (void)viewDidLoad {
	BCTextView *textView = [[[BCTextView alloc] initWithHTML:@"hello <b>world</b> <i>holla</i>. Alas, the sun is shining! <u>hi</u>"] 
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
